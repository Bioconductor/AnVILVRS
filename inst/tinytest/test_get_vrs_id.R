library(reticulate)

exit_if_not(
    virtualenv_exists("vrs_env")
)

use_virtualenv("vrs_env", required = TRUE)

expect_identical(
    get_vrs_id("chr7-87509329-A-G", "gnomad"),
    "ga4gh:VA.Zr-4BQqp-pxp9Mh4MDvd7QYuUar72zzV"
)

expect_identical(
    get_vrs_id("NC_000005.10:80656509:C:TT", "spdi"),
    "ga4gh:VA.LK_4rOVxyEwrEpaOVd-BDFV0ocbO5vgV"
)

expect_identical(
    get_vrs_id("NC_000005.10:g.80656510delinsTT", "hgvs"),
    "ga4gh:VA.LK_4rOVxyEwrEpaOVd-BDFV0ocbO5vgV"
)

expect_identical(
    get_vrs_id("5:80656489C>T", "beacon"),
    "ga4gh:VA.ebezGL6HoAhtGJyVnB_mE5BH18ntKev4"
)

variant <- "NC_000005.10:g.80656510delinsTT"
allele <- get_vrs_allele(variant, "hgvs")
expect_true(
    inherits(allele, "python.builtin.object")
)

expect_identical(
    get_variant_from_allele(allele, "hgvs"),
    variant
)

