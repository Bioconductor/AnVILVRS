.anvilvrs <- local({
    .anvilvrs <- NULL
    function() {
        if (is.null(.anvilvrs))
            .anvilvrs <<- reticulate::import("vrs_anvil")
        .anvilvrs
    }
})

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

.caf <- local({
    .caf <- NULL
    function() {
        if (is.null(.caf))
            .caf <<- reticulate::import_from_path(
                module = "caf",
                path = system.file("python", package = "AnVILVRS")
            )
        .caf
    }
})
