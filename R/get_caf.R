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
#' @examplesIf interactive()
#'   library(reticulate)
#'   ## OR use full path to vrs_env
#'   use_virtualenv("vrs_env", required = TRUE)
#'   vcf <- "vrs_anvil_toolkit/tests/fixtures/1kGP.chr1.1000.vrs.vcf.gz"
#'   vcf_index <- "1000g_chr1_index.db"
#'   variant_id <- "chr1-20094-TAA-T"
#'   vrs_id <- get_vrs_id(variant_id, "gnomad")
#'   get_caf(vrs_id, vcf, vcf_index, "USA")
#' @export
get_caf <-
    function(vrs_id, vcf, vcf_index, phenotype = "USA")
{
    reticulate::py_run_string("import sys")
    ## append 1000g path for plugin system (use full path)
    reticulate::py_run_string(
        "sys.path.append('vrs_anvil_toolkit/1000g')"
    )
    module <- .caf()
    tg_plugin <- module$initialize_plugin(
        "ThousandGenomesPlugin",
        ## download from anvil-datastorage/AnVIL_1000G_PRIMED-data-model/data
        ## workspace with avcopy
        phenotype_table_path = "./data/population_descriptor.tsv"
    )

    module$calculate_caf(
        vrs_id = vrs_id,
        vcf_path = vcf,
        vcf_index_path = vcf_index,
        phenotype = phenotype,
        plugin_object = tg_plugin
    )
}
