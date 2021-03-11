#' Load data from given directory.
#'
#' @param data_dir data directory to load from
#' @return tibble with loaded data
load_data_csv <- function (data_dir) {

    # TODO Rewrite to use recursive list.files to find any CSV and parse metadata afterwards.

    result <- tibble ()

    vm_dirs <- list.files (data_dir, '^[[:alnum:][:punct:]]+$', include.dirs = TRUE, full.names = TRUE)
    for (vm_dir in vm_dirs) {
        vm_name <- basename (vm_dir)

        data_files <- list.files (vm_dir, '^[[:alnum:][:punct:]]+\\.csv\\.xz$', full.names = TRUE)
        for (data_file in data_files) {
            data_name <- basename (data_file)
            data_split <- strsplit (data_name, '\\.csv\\.xz') [[1]]
            benchmark_name <- data_split [1]

            data_read <- suppressMessages (read_csv (data_file, col_types = cols (.default = col_double ())))
            descriptor <- tibble (benchmark = benchmark_name, vm = vm_name)
            result <- bind_rows (result, crossing (descriptor, data_read))
        }
    }

    return (result)
}
