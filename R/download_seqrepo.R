.SEQREPO_URI_GS <- "gs://fc-ac808237-aa41-4ed4-b488-311a6681002b/seqrepo.tar.gz"

#' Download SeqRepo Archive
#'
#' Download a SeqRepo archive from a specified URI to a local directory.
#' Defaults to a known Google Storage URI.
#'
#' @param uri `character(1)` The URI pointing to a Google Storage location where
#'   the `seqrepo.tar.gz` file is hosted.
#'
#' @param destdir `character(1)` The local directory where the file should be
#'   downloaded. Defaults to the user's home directory.
#'
#' @param ... Additional arguments passed to `avcopy()`.
#'
#' @importFrom AnVILGCP avcopy
#'
#' @examplesIf interactive()
#' download_seqrepo(destdir = tempdir())
#' @export
download_seqrepo <- function(uri = .SEQREPO_URI_GS, destdir = "~/", ...) {
    destdir <- normalizePath(destdir)
    stopifnot(dir.exists(destdir))

    destfile <- file.path(destdir, basename(uri))
    avcopy(
        source = uri,
        destination = destfile,
        ...
    )
    message("Downloaded to: ", destfile)
    untar(destfile, exdir = destdir)
    system2(
        command = "seqrepo",
        args = c("--root-directory", destfile, "update-latest")
    )
    destfile
}
