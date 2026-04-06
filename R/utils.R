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

.VRS_ANVIL_TOOLKIT_GH <- "https://github.com/gks-anvil/vrs_anvil_toolkit"

#' Set up the VRS AnVIL Toolkit repository
#'
#' The `gks-anvil/vrs_anvil_toolkit` GitHub repository is cloned to a local data
#' directory if it does not already exist. If the directory exists and
#' `update = TRUE`, the function will pull the latest changes from the remote
#' repository. The function returns the local path to the toolkit repository.
#' Note that `gert` is used to clone the repository into the local directory.
#'
#' @details The repository location is determined in order of priority:
#'   1. The `destdir` argument (if provided).
#'   2. The `AnVILVRS.toolkit_path` global option (set via
#'      `options(AnVILVRS.toolkit_path = "...")`).
#'   3. A persistent user data directory (via `tools::R_user_dir("AnVILVRS")`).
#'
#' @param destdir `character(1)` The directory to store the toolkit.
#'   Defaults to the location specified by the `AnVILVRS.toolkit_path` option or
#'   a persistent user data directory.
#'
#' @param update `logical(1)` Whether to pull the latest changes if the
#'   directory already exists.
#'
#' @importFrom BiocBaseUtils checkInstalled
#' @importFrom tools R_user_dir
#'
#' @return `character(1)` The local path to the toolkit repository
#'
#' @examplesIf interactive()
#' setup_vrs_toolkit(update = TRUE)
#'
#' @export
setup_vrs_toolkit <- function(destdir = NULL, update = FALSE) {
    if (!is.null(destdir))
        repo_path <- file.path(destdir, "vrs_anvil_toolkit") |>
            normalizePath()
    else
        repo_path <- getOption(
            "AnVILVRS.toolkit_path",
            file.path(
                tools::R_user_dir("AnVILVRS", which = "data"),
                "vrs_anvil_toolkit"
            )
        )

    BiocBaseUtils::checkInstalled("gert")

    if (dir.exists(repo_path)) {
        if (update) {
            message("Updating vrs_anvil_toolkit...")
            gert::git_pull(repo = repo_path)
        }
        return(repo_path)
    }

    parent_dir <- dirname(repo_path)
    if (!dir.exists(parent_dir))
        dir.create(parent_dir, recursive = TRUE)

    message("Cloning vrs_anvil_toolkit to: ", repo_path)
    gert::git_clone(url = .VRS_ANVIL_TOOLKIT_GH, path = repo_path)

    repo_path
}

.get_fixture_vcf <- function(fixture = "1kGP.chr1.1000.vrs.vcf.gz") {
    file.path(
        setup_vrs_toolkit(),
        paste0("tests/fixtures/", fixture)
    )
}

#' Generate a VRS-VCF index database
#'
#' Use the `vrsix` command-line tool to create a SQLite index database from a
#' VRS-annotated VCF file.
#'
#' @details This function indexes the VRS annotations in a specific 1000 Genomes
#'   project VCF fixture from the `vrs_anvil_toolkit`. Note that if the
#'   `dbfile` already exists, `vrsix` will re-process the VCF file. While
#'   it typically avoids duplicating entries in the location table, the
#'   re-scanning process can be time-consuming for large files and may increase
#'   the database file size due to metadata updates.
#'
#'   This function uses `setup_vrs_toolkit()` to find the toolkit directory and
#'   is influenced by the `AnVILVRS.toolkit_path` option.
#'
#' @param vcf `character(1)` Path to the bgzipped VCF file containing the VRS
#'   annotations. Defaults to a 1kGP fixture within the toolkit.
#'
#' @param dbfile `character(1)` The name of the index database file to be
#'   created. Defaults to "1000g_chr1_index.db". Note that the dbfile is added
#'   in the `setup_vrs_toolkit()` directory, so the full path to the generated
#'   database will be `file.path(setup_vrs_toolkit(), dbfile)`.
#'
#' @param force `logical(1)` Whether to force the generation of the index
#'   database even if it already exists. Defaults to `FALSE`.
#'
#' @return `character(1)` The normalized path to the generated index database.
#'
#' @examplesIf interactive()
#' build_vrs_index()
#'
#' @export
build_vrs_index <- function(
    vcf = .get_fixture_vcf(),
    dbfile = "1000g_chr1_index.db",
    force = FALSE
) {
    toolkit_dir <- setup_vrs_toolkit()
    db_location <- file.path(toolkit_dir, dbfile)

    if (!file.exists(db_location) || force) {
        message("Generating index database at: ", db_location)
        res <- system2(
            "vrsix",  c("load", paste0("--db-location=", db_location), vcf)
        )
    } else {
        message("Index database already exists at: ", db_location)
        res <- 0L
    }

    if (!res)
        normalizePath(db_location, mustWork = TRUE)
    else
        stop("Failed to generate index database. Check vrsix.log file")
}
