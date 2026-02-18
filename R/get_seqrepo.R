#' Run rsync on SeqRepo snapshot
#'
#' The function will 'rsync' the indicated SeqRepo snapshot using the
#' `biocommons.seqrepo` Python package. The AnVIL VRS Toolkit relies on local
#' access to the reference sequences provided by SeqRepo. Note that the 'rsync'
#' operation will require significant amounts of disk space and may take a
#' considerable amount of time to complete, depending on the size of the
#' snapshot being downloaded and the speed of your internet connection.
#'
#' @details The function checks for the presence of `rsync` in the system's
#' `PATH` and will throw an error if it is not found. If `rsync` is available,
#' the function will execute the `seqrepo pull` command to download the
#' reference data to the specified destination directory. The function returns
#' the path to the local directory where the SeqRepo data has been downloaded.
#'
#' @param snapshot `character(1)` The snapshot date of the SeqRepo database to
#'   download. Defaults to "2024-12-20". The snapshot date should correspond to
#'   a valid snapshot available in the SeqRepo database. You can check available
#'   snapshots at the SeqRepo repository or documentation.
#'
#' @param uri `character(1)` DEPRECATED The URI pointing to a Google Storage
#'   location where the `seqrepo.tar.gz` file is hosted.
#'
#' @param destdir `character(1)` The local directory where the file should be
#'   downloaded. Defaults to the current working directory.
#'
#' @param ... Additional arguments passed to `AnVILGCP::avcopy()`. Currently
#'   ignored as the function uses `rsync` to download the SeqRepo data instead
#'   of `avcopy()`.
#'
#' @seealso <https://dl.biocommons.org/seqrepo/>
#'
#' @importFrom AnVILGCP avcopy
#' @importFrom utils untar
#'
#' @examplesIf interactive()
#' get_seqrepo(destdir = tempdir())
#' @export
get_seqrepo <- function(destdir = "./", snapshot = "2024-12-20", ..., uri) {
    if (!missing(uri) || length(list(...)))
        stop(
            "The 'uri' argument and additional arguments passed via '...' are ",
            "deprecated and will be ignored.\nThe function now uses 'rsync' ",
            "to download SeqRepo data directly from biocommons.org.",
            call. = FALSE
        )
    reticulate::py_run_string("import biocommons.seqrepo")
    destdir <- normalizePath(destdir, mustWork = FALSE)
    if (!dir.exists(destdir))
        dir.create(destdir)

    if (!nzchar(Sys.which("rsync"))) {
        stop(
            "'rsync' is not found in your system's PATH. ",
            "'seqrepo pull' requires 'rsync' to download the database.\n",
            "Please install 'rsync'. For example, on Debian/Ubuntu, run:\n",
            "    sudo apt-get update && sudo apt-get install -y rsync",
            call. = FALSE
        )
    }
    message("Downloading seqrepo snapshot to: ", destdir)
    system2(
        command = "seqrepo",
        args = c("--root-directory", destdir, "pull -i", snapshot)
    )
    destdir
}
