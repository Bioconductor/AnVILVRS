#' @export
.anvilvrs <- local({
    .anvilvrs <- NULL
    function() {
        if (is.null(.anvilvrs))
            .anvilvrs <<- reticulate::import("vrs_anvil")
        .anvilvrs
    }
})
