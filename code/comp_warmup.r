.WARMUP_TOTAL_LIMIT <- 5*60

#' Tag data with warm vs cold information.
comp_warm <- function (data) {
    # Any iteration started after warmup limit is warm.
    # Any iteration started before warmup limit is cold.
    # This is rather simple but avoids introducing arbitrary detection algoritm.
    return (data %>% mutate (warm = (total - time) >= .WARMUP_TOTAL_LIMIT))
}
