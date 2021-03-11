extract_time_from_nanos <- function (data_read) {
    # Normalized iteration time.
    column_time <- data_read [['nanos']] / 1e9

    return (column_time)
}


extract_time_from_duration <- function (data_read) {
    # Normalized iteration time.
    column_time <- data_read [['duration_ns']] / 1e9

    return (column_time)
}


extract_cumulative_time_from_uptime <- function (data_read) {
    # Normalized cumulative time.
    column_total <- (data_read [['uptime_ns']] + data_read [['duration_ns']]) / 1e9

    return (column_total)
}

normalize_columns <- function (data_read) {
    # Replace certain characters in column  names.
    data_normalized <- rename_all (data_read, function (name) str_replace_all (name, '[-:]', '_'))

    return (data_normalized)
}


compute_index <- function (data_read) {
    # Sequential repetition index.
    column_index <- seq.int (1, nrow (data_read))

    return (column_index)
}


compute_cumulative_time_from_unix <- function (data_read) {
    # Compute cumulative time.
    # We only have second resolution timestamps
    # so we use those to stretch cumulative time.
    column_time <- data_read [['nanos']] / 1e9
    column_total <- cumsum (column_time)
    time_nano_interval <- last (column_total)
    time_unix_beg <- first (data_read [['unixts.before']])
    time_unix_end <- last (data_read [['unixts.after']])
    time_unix_interval <- (time_unix_end - time_unix_beg) / 1e3
    time_scale <- time_unix_interval / time_nano_interval
    column_total <- column_total * time_scale

    return (column_total)
}


extract_data_version_2 <- function (data_json, benchmark) {

    data_read <- as_tibble (data_json [['results']] [[benchmark]])
    assert_that (is_tibble (data_read))
    assert_that (nrow (data_read) > 0)

    # Transform basic columns into canonical form.
    column_time <- extract_time_from_nanos (data_read)
    column_total <- compute_cumulative_time_from_unix (data_read)
    column_index <- compute_index (data_read)

    # Preserve optional columns not transformed into canonical form.
    data_extra <- normalize_columns (select (data_read, -nanos, -unixts.before, -unixts.after))

    return (bind_cols (tibble (time = column_time, total = column_total, index = column_index), data_extra))
}


extract_data_version_4 <- function (data_json, benchmark) {

    data_read <- as_tibble (data_json [['data']] [[benchmark]] [['results']])
    assert_that (is_tibble (data_read))
    assert_that (nrow (data_read) > 0)

    # Transform basic columns into canonical form.
    column_time <- extract_time_from_nanos (data_read)
    column_total <- compute_cumulative_time_from_unix (data_read)
    column_index <- compute_index (data_read)

    # Preserve optional columns not transformed into canonical form.
    data_extra <- normalize_columns (select (data_read, -nanos, -unixts.before, -unixts.after))

    return (bind_cols (tibble (time = column_time, total = column_total, index = column_index), data_extra))
}


extract_data_version_5 <- function (data_json, benchmark) {

    data_read <- as_tibble (data_json [['data']] [[benchmark]] [['results']])
    assert_that (is_tibble (data_read))
    assert_that (nrow (data_read) > 0)

    # Transform basic columns into canonical form.
    column_time <- extract_time_from_duration (data_read)
    column_total <- extract_cumulative_time_from_uptime (data_read)
    column_index <- compute_index (data_read)

    # Preserve optional columns not transformed into canonical form.
    data_extra <- normalize_columns (select (data_read, -duration_ns, -uptime_ns))

    return (bind_cols (tibble (time = column_time, total = column_total, index = column_index), data_extra))
}


#' Load data from given directory.
#'
#' @param data_path data directory to load from
#' @return tibble with loaded data
load_data_json <- function (data_path) {

    log_info ('Loading data from {data_path} ...')

    result <- tibble (
        vm_name = factor (),
        vm_version = factor (),
        vm_configuration = factor (),
        benchmark = factor (),
        run = factor ())

    data_file_list <- list.files (data_path, '\\.json(|\\.gz|\\.xz|\\.bz2)$', recursive = TRUE, full.names = TRUE)
    for (data_file_name in data_file_list) {

        data_json <- fromJSON (data_file_name)

        version <- data_json [['format_version']]

        # Lacking better source the file name is good run id.
        meta_vm_name <- data_json [['environment']] [['vm']] [['name']]
        meta_vm_version <- data_json [['environment']] [['vm']] [['version']]
        meta_vm_configuration <- paste (data_json [['environment']] [['vm']] [['args']], collapse = ' ')

        meta_benchmark_list <- data_json [['benchmarks']]
        meta_run_name <- data_file_name

        for (meta_benchmark_name in meta_benchmark_list) {

            data_read <- NULL
            if (version == 2) data_read <- extract_data_version_2 (data_json, meta_benchmark_name)
            if (version == 4) data_read <- extract_data_version_4 (data_json, meta_benchmark_name)
            if (version == 5) data_read <- extract_data_version_5 (data_json, meta_benchmark_name)

            if (!is_tibble (data_read) || nrow (data_read) == 0) {
                log_warn ('Results for benchmark {meta_benchmark_name} in file {data_file_name} damaged.')
                next
            }

            # Put everything together.
            data_read [['run']] <- factor (meta_run_name)
            data_read [['vm_name']] <- factor (meta_vm_name)
            data_read [['vm_version']] <- factor (meta_vm_version)
            data_read [['vm_configuration']] <- factor (meta_vm_configuration)
            data_read [['benchmark']] <- factor (meta_benchmark_name)

            result <- bind_rows_with_factor_merger (result, data_read, c ('vm_name', 'vm_version', 'vm_configuration', 'run', 'benchmark'))
        }
    }

    log_info ('... loaded {nrow (result)} points in {nlevels (result [["run"]])} runs.')

    return (result)
}
