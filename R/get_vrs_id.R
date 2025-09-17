#' Translate a Variant to a VRS ID
#'
#' This function uses a Python backend to translate a variant identifier
#' (e.g., gnomad format) into a GA4GH VRS Allele ID.
#'
#' @param variant_id `character(1)` A string of the variant to translate.
#'
#' @param from_format `character(1)` One of "gnomad", "spdi", or "hgvs" formats
#'   indicating the format of the input `variant_id`. The abbreviations
#'   stand for Genome Aggregation Database, Sequence Position Deletion
#'   Insertion, and Human Genome Variation Society, respectively. the respective
#'   variant representation. Defaults to "gnomad".
#'
#' @return A character string containing the VRS ID.
#'
#' @export
#'
#' @examplesIf interactive()
#'   use_virtualenv("vrs_env", required = TRUE)
#'
#'   get_vrs_id("chr7-87509329-A-G", "gnomad")
#'   get_vrs_id("NC_000005.10:80656509:C:TT", "spdi")
#'   get_vrs_id("NC_000005.10:g.80656510delinsTT", "hgvs")
#' @export
get_vrs_id <- function(variant_id, from_format = c("gnomad", "spdi", "hgvs")) {
    from_format <- match.arg(from_format)
    module <- .vrs_translator()
    module$get_vrs_id_from_variant(variant_id, from_format)
}

