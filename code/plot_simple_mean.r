plot_mean_bar <- function (data, suffix, title, metric_label, metric_unit) {
    log_info ('Plotting "{metric_label}" mean bar plot for "{suffix}" ...')
    nice <- ggplot (data) +
        geom_col (aes (x = vm, y = avg, fill = vm), color = 'black') +
        geom_errorbar (aes (x = vm, ymin = lo, ymax = hi), width = 0.5) +
        facet_wrap (vars (benchmark), nrow = PLOT_ROWS, scales = 'free_y') +
        theme (legend.position = 'none', axis.text.x = element_text (angle = 90, vjust = 0.5, hjust = 1)) +
        labs (
            x = NULL,
            y = sprintf ('Mean single repetition %s [%s]', metric_label, metric_unit),
            title = title) +
        scale_fill_brewer (palette = 'Blues', type = 'qual')
    plot_save (nice, c ('mean', 'bar', suffix))
}
