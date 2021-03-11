#' Compute ratio with confidence interval.
.get_ratio_with_ci <- function (data, key, orig, base_name, metric_name) {

    # Get the baseline from the original data.
    base_data <- orig %>% filter (benchmark == key $ benchmark, vm == base_name)
    if (nrow (base_data) == 0) return (tibble (avg = NA, lo = NA, hi = NA))

    # We work on run means for speed.
    data_runs <- get_run_means (data, metric_name)
    base_runs <- get_run_means (base_data, metric_name)

    # Do not even try with one run.
    if ((length (data_runs) > 1) && (length (base_runs) > 1)) {

        # Helper function for stratified bootstrap.
        meanify <- function (data, index) {
            data_top <- data $ value [index [data $ strata]]
            data_bot <- data $ value [index [!data $ strata]]
            return (mean (data_top) / mean (data_bot))
        }

        # Stratified bootstrap computation.
        means_tibble <- bind_rows (tibble (value = data_runs, strata = FALSE), tibble (value = base_runs, strata = TRUE))
        ratio_boot <- boot (means_tibble, meanify, R = REPLICATES, strata = means_tibble $ strata)

        # The computations can fail so fall back to something if they do.
        ratio_ci <- tryCatch (boot.ci (ratio_boot, type = 'bca', conf = CONFIDENCE), error = function (e) NA)
        if (!is.null (ratio_ci) && !any (is.na (ratio_ci))) return (tibble (avg = ratio_boot $ t0, lo = ratio_ci $ bca [1,4], hi = ratio_ci $ bca [1,5]))
        ratio_ci <- tryCatch (boot.ci (ratio_boot, type = 'basic', conf = CONFIDENCE), error = function (e) NA)
        if (!is.null (ratio_ci) && !any (is.na (ratio_ci))) return (tibble (avg = ratio_boot $ t0, lo = ratio_ci $ basic [1,4], hi = ratio_ci $ basic [1,5]))
    }

    return (tibble (avg = mean (base_runs) / mean (data_runs), lo = NA, hi = NA))
}


#' Compute ratio with confidence intervals per given group and base name.
comp_ratio_with_ci <- function (data, base_name, metric_name) {
    return (data %>% group_modify (.get_ratio_with_ci, data, base_name, metric_name))
}
