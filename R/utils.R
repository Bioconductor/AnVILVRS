.POP_DESC_URI <- paste0(
    "gs://fc-2ee2ca2a-a140-48a1-b793-e27badb7945d/",
    "data_tables/",
    "population_descriptor.tsv"
)

#' Downloads the population descriptor file to the BiocFileCache
#' from a known Google Storage URI.
#'
#' @param uri `character(1)` The URI pointing to a Google Storage location where
#'   the `population_descriptor.tsv` file is hosted.
#'
#' @param ... Additional arguments passed to `AnVILGCP::avcopy()`.
#'
#' @importFrom AnVILGCP avcopy
#' @importFrom BiocFileCache BiocFileCache bfcadd bfcquery bfcrpath
#' @importFrom tools R_user_dir
#'
#' @returns `character(1)` The local file path to the downloaded population
#'   descriptor file
#'
#' @examplesIf interactive()
#' get_pop_descriptor()
#' @export
get_pop_descriptor <- function(uri = .POP_DESC_URI, ...) {
    cache <- tools::R_user_dir("AnVILVRS", which = "cache")
    bfc <- BiocFileCache::BiocFileCache(cache)
    rid <- BiocFileCache::bfcquery(bfc, query = uri, field = "rname")$rid
    if (!length(rid)) {
        message("Downloading population descriptor...")
        destfile <- tempfile(fileext = ".tsv")
        AnVILGCP::avcopy(
            source = uri,
            destination = destfile,
            ...
        )
        rid <- BiocFileCache::bfcadd(bfc, rname = uri, fpath = destfile) |>
            names()
    } else {
        message("Found in BiocFileCache: ", rid)
    }
    BiocFileCache::bfcrpath(bfc, rids = rid)
}
