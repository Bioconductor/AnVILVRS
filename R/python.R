#' @export
.anvilvrs <- local({
    .anvilvrs <- NULL
    function() {
        if (is.null(.anvilvrs))
            .anvilvrs <<- reticulate::import("vrs_anvil")
        .anvilvrs
    }
})

#' @export
.vrs_translator <- local({
    .vrs_translator <- NULL
    function() {
        if (is.null(.vrs_translator))
            .vrs_translator <<- reticulate::import_from_path(
                module = "vrs_translator",
                path = system.file("python", package = "AnVILVRS")
            )
        .vrs_translator
    }
})
