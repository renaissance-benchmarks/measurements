.flag_sample_outliers_global <- function (data) {
    limits <- quantile (data, c (OUTLIER_LIMIT, 1 - OUTLIER_LIMIT))
    range <- limits [2] - limits [1]
    limit_lo <- limits [1] - range * OUTLIER_SLACK
    limit_hi <- limits [2] + range * OUTLIER_SLACK
    return (data < limit_lo | data > limit_hi)
}


.flag_sample_outliers_window <- function (data) {
    # For less data than window size use global filter.
    if (length (data) < OUTLIER_WINDOW) return (.flag_sample_outliers_global (data))
    # Compute window limits.
    # This is terribly inefficient.
    # Consider incremental computation.
    windows <- seq.int (1, length (data) - OUTLIER_WINDOW + 1)
    limits <- sapply (windows, function (window) quantile (data [window : (window + OUTLIER_WINDOW - 1)], c (OUTLIER_LIMIT, 1 - OUTLIER_LIMIT)))
    ranges <- limits [2, ] - limits [1, ]
    limits_lo <- limits [1, ] - ranges * OUTLIER_SLACK
    limits_hi <- limits [2, ] + ranges * OUTLIER_SLACK
    # Stretch limits across boundary cases.
    limits_lo <- c (rep.int (first (limits_lo), floor ((OUTLIER_WINDOW - 1) / 2)), limits_lo, rep (last (limits_lo), ceiling ((OUTLIER_WINDOW - 1) / 2)))
    limits_hi <- c (rep.int (first (limits_hi), floor ((OUTLIER_WINDOW - 1) / 2)), limits_hi, rep (last (limits_hi), ceiling ((OUTLIER_WINDOW - 1) / 2)))
    return (data < limits_lo | data > limits_hi)
}


.get_change_points <- function (data, key, metric_name) {
    # Uses settings from https://doi.org/10.1145/3133876.
    indices <- tryCatch (
        cpts (cpt.meanvar (data [[metric_name]], method = 'PELT', penalty = 'Manual', pen.value = 15 * log (nrow (data)))),
        error = function (e) return (NULL))
    return (tibble (change = data $ total [indices]))
}


plot_samples_violin <- function (data, outliers, suffix, title, metric_name, metric_label, metric_unit) {
    log_info ('Plotting "{metric_label}" samples violin plot for "{suffix}" ...')
    metric_symbol <- sym (metric_name)
    if (outliers) {
        # Mild outlier filtering is useful to prevent excess scale compression.
        # It would be better to achieve the same with fixed scale
        # but apparently faceting does not support it.
        # Outliers are picked per run to avoid
        # excluding entire run.
        data <- data %>% group_by (benchmark, run, vm) %>% filter (!.flag_sample_outliers_window (!!metric_symbol)) %>% ungroup ()
    }
    nice <- ggplot (data) +
        geom_violin (aes (x = vm, y = !!metric_symbol, fill = vm), scale = 'width', width = 1) +
        geom_boxplot (aes (x = vm, y = !!metric_symbol), width = 0.2) +
        facet_wrap (vars (benchmark), nrow = PLOT_ROWS, scales = 'free_y') +
        theme (legend.position = 'none', axis.text.x = element_text (angle = 90, vjust = 0.5, hjust = 1)) +
        labs (
            x = NULL,
            y = sprintf ('Single repetition %s [%s]', metric_label, metric_unit),
            title = title) +
        scale_fill_brewer (palette = 'Blues', type = 'qual')
    plot_save (nice, c ('samples', 'violin', suffix))
}


.plot_samples_scatter_single_benchmark <- function (data, key, outliers, suffix, title, metric_name, metric_label, metric_unit) {
    log_info ('Plotting "{metric_label}" samples scatter plot for "{suffix}" "{as.character (key [["benchmark"]])}" ...')
    metric_symbol <- sym (metric_name)
    if (outliers) {
        # Outliers are picked per run to avoid excluding entire run.
        # Watch out about grouping, benchmark is already grouped externally.
        data <- data %>% group_by (vm, run) %>% filter (!.flag_sample_outliers_window (!!metric_symbol)) %>% ungroup ()
    }
    # Add change point lines to data.
    changes <- data %>% group_by (vm, run) %>% group_modify (.get_change_points, metric_name)
    # Plot with change point lines.
    nice <- ggplot (data) +
        geom_point (aes (x = total, y = !!metric_symbol, color = run), alpha = 1/2) +
        geom_vline (data = changes, aes (xintercept = change, color = run), alpha = 1/3) +
        facet_wrap (vars (vm), ncol = 1, scales = 'free_y') +
        theme (legend.position = 'none') +
        labs (
            x = 'Accumulated execution time [s]',
            y = sprintf ('Single repetition %s [%s]', metric_label, metric_unit),
            title = sprintf ('%s (%s)', title, as.character (key $ benchmark)))
    plot_save (nice, c ('samples', 'scatter', suffix, as.character (key $ benchmark)))
}


plot_samples_scatter <- function (data, outliers, suffix, title, metric_name, metric_label, metric_unit) {
    data %>% group_by (benchmark) %>% group_walk (.plot_samples_scatter_single_benchmark, outliers, suffix, title, metric_name, metric_label, metric_unit)
}
