#' Downloads the population descriptor file to the specified directory
#' from a known Google Storage URI.
#'
#' @param destdir `character(1)` The local directory where the file should be
#'  downloaded. Defaults to the current working directory.
#'
#' @param ... Additional arguments passed to `AnVILGCP::avcopy()`.
#'
#' @importFrom AnVILGCP avcopy
#'
#' @examplesIf interactive()
#' get_pop_descriptor(destdir = tempdir())
#' @export
get_pop_descriptor <- function(destdir = ".", ...) {
    destdir <- normalizePath(destdir)
    stopifnot(dir.exists(destdir))

    uri <- paste0(
        "gs://fc-2ee2ca2a-a140-48a1-b793-e27badb7945d/",
        "data_tables/",
        "population_descriptor.tsv"
    )
    destfile <- file.path(destdir, basename(uri))
    AnVILGCP::avcopy(
        source = uri,
        destination = destfile
    )
    message("Downloaded to: ", destfile)
    destfile
}
