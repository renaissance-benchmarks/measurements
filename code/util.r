#' Tibble factor merger.
factor_merger <- function (one, two, cols) {
    for (col in cols) {
        combined <- as.list (lvls_union (list (one [[col]], two [[col]])))
        names (combined) <- combined
        levels (one [[col]]) <- combined
        levels (two [[col]]) <- combined
    }
    return (list (one, two))
}


#' Tibble anti_join with factor merger.
anti_join_with_factor_merger <- function (one, two, cols) {
    c (one, two) %<-% factor_merger (one, two, cols)
    return (anti_join (one, two, by = cols))
}


#' Tibble left_join with factor merger.
left_join_with_factor_merger <- function (one, two, cols) {
    c (one, two) %<-% factor_merger (one, two, cols)
    return (left_join (one, two, by = cols))
}


#' Tibble bind_rows with factor merger.
bind_rows_with_factor_merger <- function (one, two, cols) {
    c (one, two) %<-% factor_merger (one, two, cols)
    return (bind_rows (one, two))
}
