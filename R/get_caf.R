#' Get the allele frequency from 1000 Genomes Project VCF file
#'
#' @param vrs_id `character(1)` A GA4GH VRS Allele ID
#'
#' @param vcf `character(1)` Path to a bgzipped VCF file containing 1000 Genomes
#'    Project variants with allele frequency annotations.
#'
#' @param vcf_index `character(1)` Path to the index file for the VCF file.
#'
#' @param phenotype `character(1)` Population or super-population code from the
#'   1000 Genomes Project. See `anvil-datastorage/AnVIL_1000G_PRIMED-data-model`
#'   workspace under `data/population_descriptor.tsv` for valid codes. Defaults
#'   to "USA".
#'
#' @param pop_desc_file `character(1)` Path to the population descriptor file
#'   downloaded from the AnVIL_1000G_PRIMED-data-model workspace. If `NULL`
#'   (default), the file will be downloaded to a temporary directory.
#'
#' @param toolkit_dir `character(1)` Path to the directory containing the
#'   `vrs_anvil_toolkit/1000g` subdirectory. If `NULL` (default), the toolkit
#'   will be cloned to a user data directory using `setup_vrs_toolkit()`.
#'
#' @returns a `list()` response including `$focusAlleleFrequency`
#'
#' @examplesIf interactive()
#'   library(reticulate)
#'   ## OR use full path to vrs_env
#'   use_virtualenv("vrs_env", required = TRUE)
#'   toolkit_dir <- setup_vrs_toolkit()
#'   vcf <- AnVILVRS:::.get_fixture_vcf()
#'   vcf_index <- build_vrs_index()
#'   variant_id <- "chr1-20094-TAA-T"
#'   vrs_id <- get_vrs_id(variant_id, "gnomad")
#'   pop_desc <- get_pop_descriptor()
#'   get_caf(
#'     vrs_id, vcf, vcf_index, "USA",
#'     pop_desc_file = pop_desc
#'   )
#' @export
get_caf <- function(
    vrs_id, vcf, vcf_index, phenotype = "USA",
    pop_desc_file = NULL, toolkit_dir = setup_vrs_toolkit()
) {
    toolkit_dir <- normalizePath(toolkit_dir)
    reticulate::py_run_string("import sys")

    # 1. Add 'src' to Python's search path for vrs_anvil and plugin_system
    reticulate::py_run_string(
        paste0("sys.path.append('", file.path(toolkit_dir, "src"), "')")
    )
    # 2. Add '1000g' for plugin system (use full path)
    reticulate::py_run_string(
        paste0("sys.path.append('", file.path(toolkit_dir, "1000g"), "')")
    )

    module <- .caf()
    if (is.null(pop_desc_file))
        pop_desc_file <- get_pop_descriptor(tempdir())
    else
        stopifnot(file.exists(pop_desc_file))
    tg_plugin <- module$initialize_plugin(
        "ThousandGenomesPlugin",
        ## download from anvil-datastorage/AnVIL_1000G_PRIMED-data-model/data
        ## workspace with avcopy
        phenotype_table_path = pop_desc_file
    )

    module$calculate_caf(
        vrs_id = vrs_id,
        vcf_path = vcf,
        vcf_index_path = vcf_index,
        phenotype = phenotype,
        plugin_object = tg_plugin
    )
}
