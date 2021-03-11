#' Compute arithmetic mean per run.
get_run_means <- function (data, metric_name) {
    # Handle empty data separately because grouping complains otherwise.
    if (nrow (data) > 0) {
        metric_symbol <- sym (metric_name)
        return (data %>% group_by (run) %>% summarize (avg = mean (!!metric_symbol), .groups = 'drop') %>% pull (avg))
    }
    return (NULL)
}
