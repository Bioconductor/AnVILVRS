#' Translate a Variant to a VRS ID
#'
#' This function uses a Python backend to translate a variant identifier
#' (e.g., gnomad format) into a GA4GH VRS Allele ID.
#'
#' @param variant_id `character(1)` A string of the variant to translate.
#'
#' @param from_format `character(1)` One of "gnomad", "spdi", "hgvs", or
#'   "beacon" formats indicating the format of the input `variant_id`. The
#'   abbreviations stand for Genome Aggregation Database, Sequence Position
#'   Deletion Insertion, Human Genome Variation Society, and Beacon
#'   nomenclature, respectively. the respective variant representation. Defaults
#'   to "gnomad".
#'
#' @return A character string containing the VRS ID.
#'
#' @examplesIf interactive()
#'   library(reticulate)
#'   use_virtualenv("vrs_env", required = TRUE)
#'
#'   get_vrs_id("chr7-87509329-A-G", "gnomad")
#'   get_vrs_id("NC_000005.10:80656509:C:TT", "spdi")
#'   get_vrs_id("NC_000005.10:g.80656510delinsTT", "hgvs")
#'   get_vrs_id("5 : 80656489 C > T", "beacon")
#'
#'   get_vrs_allele("NC_000005.10:g.80656510delinsTT", "hgvs")
#'   get_vrs_allele("5-80656489-C-T", "gnomad")
#'
#'   allele <- get_vrs_allele("5 : 80656489 C > T", "beacon")
#'   get_variant_from_allele(allele, "hgvs")
#'
#'   allele <- get_vrs_allele("NC_000005.10:g.80656510delinsTT", "hgvs")
#'   get_variant_from_allele(allele, "spdi")
#' @export
get_vrs_id <-
    function(variant_id, from_format = c("gnomad", "spdi", "hgvs", "beacon"))
{
    from_format <- match.arg(from_format)
    module <- .vrs_translator()
    module$get_vrs_id_from_variant(variant_id, from_format)
}

#' @rdname get_vrs_id
#' @export
get_vrs_allele <-
    function(variant_id, from_format = c("gnomad", "spdi", "hgvs", "beacon"))
{
    from_format <- match.arg(from_format)
    module <- .vrs_translator()
    module$get_vrs_allele_from_variant(variant_id, from_format)
}

#' @rdname get_vrs_id
#' @export
get_variant_from_allele <-
    function(allele, to_format = c("gnomad", "spdi", "hgvs", "beacon"))
{
    to_format <- match.arg(to_format)
    module <- .vrs_translator()
    module$get_variant_from_allele(allele, to_format)
}
