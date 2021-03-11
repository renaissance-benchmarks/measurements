#' Write plot to file.
plot_save <- function (nice, name) {
    complete <- paste (name, collapse = '-')
    ggsave (sprintf ('%s.png', complete), nice, width = PLOT_WIDTH, height = PLOT_HEIGHT, unit = 'mm')
}
