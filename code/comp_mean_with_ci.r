#' Compute arithmetic mean with confidence interval.
.get_mean_with_ci <- function (data, key, metric_name) {
    # Key not used but supplied by group map calls.

    # We work on run means for speed.
    runs <- get_run_means (data, metric_name)

    # Do not even try with one run.
    if (length (runs) > 1) {

        # Standard bootstrap computation.
        mean_boot <- boot (runs, function (d, i) mean (d [i]), R = REPLICATES)

        # The computations can fail so fall back to something if they do.
        mean_ci <- tryCatch (boot.ci (mean_boot, type = 'bca', conf = CONFIDENCE), error = function (e) NA)
        if (!is.null (mean_ci) && !any (is.na (mean_ci))) return (tibble (avg = mean_boot $ t0, lo = mean_ci $ bca [1,4], hi = mean_ci $ bca [1,5]))
        mean_ci <- tryCatch (boot.ci (mean_boot, type = 'basic', conf = CONFIDENCE), error = function (e) NA)
        if (!is.null (mean_ci) && !any (is.na (mean_ci))) return (tibble (avg = mean_boot $ t0, lo = mean_ci $ basic [1,4], hi = mean_ci $ basic [1,5]))
    }

    return (tibble (avg = mean (runs), lo = NA, hi = NA))
}


#' Compute arithmetic means with confidence intervals per given group.
comp_mean_with_ci <- function (data, metric_name) {
    return (data %>% group_modify (.get_mean_with_ci, metric_name))
}
