
# AnVILVRS

# Introduction

The AnVILVRS package provides an R interface to the [AnVIL VRS
Toolkit](https://pypi.org/project/vrs-anvil-toolkit/), a Python library
for working with the [Global Alliance for Genomics and Health (GA4GH)
Variation Representation Specification
(VRS)](https://vrs.ga4gh.org/en/stable/) standard. The package allows
users to translate variant identifiers from various formats (e.g.,
gnomAD, SPDI, HGVS, Beacon) into GA4GH VRS Allele IDs and vice versa.
Additionally, it provides functionality to retrieve allele frequency
data from the 1000 Genomes Project based on VRS Allele IDs.

# Installation

To use the AnVILVRS package, you need to have Python installed on your
system. The package requires Python 3.11, so ensure that you have this
version installed.

Install the AnVILVRS package from Bioconductor with:

``` r
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install("AnVILVRS")
```

# Loading and Setup

Load the `AnVILVRS` package and the
*[reticulate](https://CRAN.R-project.org/package=reticulate)* package
for Python integration:

``` r
library(AnVILVRS)
library(reticulate)
```

After installing the package, you need to set up a Python virtual
environment with the required dependencies. You can do this by running
the following command in R:

``` r
install_AnVILVRS(envname = "vrs_env")
```

# Usage

Once the virtual environment is set up, you can use the AnVILVRS package
to translate variant identifiers and retrieve allele frequency data.
First, load the package and activate the virtual environment:

``` r
use_virtualenv("vrs_env", required = TRUE)
```

## Translating Variant Identifiers

You can translate variant identifiers from various formats into GA4GH
VRS Allele IDs using the `get_vrs_id` function. Supported formats
include “gnomad”, “spdi”, “hgvs”, and “beacon”.

``` r
get_vrs_id("chr7-87509329-A-G", "gnomad")
#> [1] "ga4gh:VA.Zr-4BQqp-pxp9Mh4MDvd7QYuUar72zzV"
get_vrs_id("NC_000005.10:80656509:C:TT", "spdi")
#> [1] "ga4gh:VA.LK_4rOVxyEwrEpaOVd-BDFV0ocbO5vgV"
get_vrs_id("NC_000005.10:g.80656510delinsTT", "hgvs")
#> [1] "ga4gh:VA.LK_4rOVxyEwrEpaOVd-BDFV0ocbO5vgV"
get_vrs_id("5 : 80656489 C > T", "beacon")
#> [1] "ga4gh:VA.ebezGL6HoAhtGJyVnB_mE5BH18ntKev4"
```

## Allele Object Retrieval

You can also retrieve the VRS Allele object using the `get_vrs_allele`
function:

``` r
allele <- get_vrs_allele("5 : 80656489 C > T", "beacon")
allele
#> Allele(id='ga4gh:VA.ebezGL6HoAhtGJyVnB_mE5BH18ntKev4', type='Allele', name=None, description=None, aliases=None, extensions=None, digest='ebezGL6HoAhtGJyVnB_mE5BH18ntKev4', expressions=None, location=SequenceLocation(id='ga4gh:SL.JiLRuuyS5wefF_6-Vw7m3Yoqqb2YFkss', type='SequenceLocation', name=None, description=None, aliases=None, extensions=None, digest='JiLRuuyS5wefF_6-Vw7m3Yoqqb2YFkss', sequenceReference=SequenceReference(id=None, type='SequenceReference', name=None, description=None, aliases=None, extensions=None, refgetAccession='SQ.aUiQCzCPZ2d0csHbMSbh2NzInhonSXwI', residueAlphabet=None, circular=None, sequence=None, moleculeType=None), start=80656488, end=80656489, sequence=None), state=LiteralSequenceExpression(id=None, type='LiteralSequenceExpression', name=None, description=None, aliases=None, extensions=None, sequence=sequenceString(root='T')))
```

## Variant Retrieval from Allele Object

You can convert a VRS Allele object back to a variant identifier in a
specified format using the `get_variant_from_allele` function:

``` r
get_variant_from_allele(allele, "hgvs")
#> [1] "NC_000005.10:g.80656489C>T"
```

## Calculating Cohort Allele Frequency

### Population Descriptor table download

The `get_pop_descriptor` function downloads the population descriptor
file from a known Google Storage URI to the
*[BiocFileCache](https://bioconductor.org/packages/3.23/BiocFileCache)*.
This file is used in the calculation of the Cohort Allele Frequency
(CAF). The `get_caf` function makes use of the population descriptor
`.tsv` file to dynamically provide a Cohort Allele Frequency based on
the sub-population of interest. In our example, we will use the “USA”
population code.

``` r
library(readr)
pop_desc <- get_pop_descriptor()
#> Found in BiocFileCache: BFC2
read_tsv(
    file = pop_desc,
    col_types = cols(
        population_descriptor_id = col_character(),
        population_descriptor = col_character(),
        subject_id = col_character(),
        country_of_recruitment = col_character(),
        population_label = col_character()
    )
)
#> # A tibble: 3,202 × 5
#>    population_descriptor_id population_descriptor    subject_id country_of_recruitment population_label
#>    <chr>                    <chr>                    <chr>      <chr>                  <chr>           
#>  1 fb7368ca                 population | superpopul… HG00096    UK                     GBR | EUR       
#>  2 ada92c9c                 population | superpopul… HG00097    UK                     GBR | EUR       
#>  3 5b9b6b8c                 population | superpopul… HG00099    UK                     GBR | EUR       
#>  4 4957a17c                 population | superpopul… HG00100    UK                     GBR | EUR       
#>  5 f3e3ab5b                 population | superpopul… HG00101    UK                     GBR | EUR       
#>  6 bc1c2c8e                 population | superpopul… HG00102    UK                     GBR | EUR       
#>  7 035cf47a                 population | superpopul… HG00103    UK                     GBR | EUR       
#>  8 89ee21d5                 population | superpopul… HG00105    UK                     GBR | EUR       
#>  9 ac194313                 population | superpopul… HG00106    UK                     GBR | EUR       
#> 10 7c2b88af                 population | superpopul… HG00107    UK                     GBR | EUR       
#> # ℹ 3,192 more rows
```

### SeqRepo reference data

The `get_seqrepo` function downloads a SeqRepo archive from a specified
URI to a local directory. This is useful for setting up the SeqRepo
database required by the AnVIL VRS Toolkit.

``` r
get_seqrepo(destdir = tempdir())
```

### Cohort Allele Frequency (CAF) calculation

Finally, to calculate the Cohort Allele Frequency (CAF) using the 1000
Genomes Project based on a VRS Allele ID, use the `get_caf` function. A
`.gz` zipped VCF file and its corresponding index file obtained from the
1000 Genomes Project is needed. It should include variants with allele
frequency annotations.

``` r
use_virtualenv("vrs_env", required = TRUE)
toolkit_dir <- setup_vrs_toolkit()
vcf <- AnVILVRS:::.get_fixture_vcf()
vcf_index <- build_vrs_index()
#> Index database already exists at: /home/mramos/.local/share/R/AnVILVRS/vrs_anvil_toolkit/1000g_chr1_index.db
variant_id <- "chr1-20094-TAA-T"
vrs_id <- get_vrs_id(variant_id, "gnomad")
pop_desc <- get_pop_descriptor()
#> Found in BiocFileCache: BFC2
get_caf(
    vrs_id = vrs_id,
    vcf = vcf,
    vcf_index = vcf_index,
    phenotype = "USA",
    pop_desc_file = pop_desc,
    toolkit_dir = toolkit_dir
)
#> Initializing plugin: ThousandGenomesPlugin...
#> Plugin initialized successfully!
#> $type
#> [1] "CohortAlleleFrequencyStudyResult"
#>
#> $sourceDataSet
#> $sourceDataSet$id
#> [1] "/home/mramos/.local/share/R/AnVILVRS/vrs_anvil_toolkit/tests/fixtures/1kGP.chr1.1000.vrs.vcf.gz"
#>
#> $sourceDataSet$type
#> [1] "DataSet"
#>
#> $sourceDataSet$description
#> [1] "Created 2026-04-07 13:41:45.016470"
#>
#>
#> $ancillaryResults
#> $ancillaryResults$homozygotes
#> [1] 1
#>
#> $ancillaryResults$hemizygotes
#> [1] 246
#>
#> $ancillaryResults$phenotypes
#> [1] "USA"
#>
#>
#> $focusAllele
#> [1] "ga4gh:VA.1WRXw4TC5DYsjC2QLyKux9C0xETLN3Yt"
#>
#> $focusAlleleCount
#> [1] 248
#>
#> $locusAlleleCount
#> [1] 1184
#>
#> $focusAlleleFrequency
#> [1] 0.2094595
#>
#> $cohort
#> $cohort$id
#> [1] "USA"
#>
#> $cohort$type
#> [1] "StudyGroup"
#>
#> $cohort$name
#> [1] "USA"
```

# Session Info

<details>

<summary>

Click to expand session info
</summary>

``` r
sessionInfo()
#> R version 4.6.0 alpha (2026-03-28 r89737)
#> Platform: x86_64-pc-linux-gnu
#> Running under: Ubuntu 24.04.4 LTS
#>
#> Matrix products: default
#> BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3
#> LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.26.so;  LAPACK version 3.12.0
#>
#> locale:
#>  [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C               LC_TIME=en_US.UTF-8
#>  [4] LC_COLLATE=en_US.UTF-8     LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8
#>  [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                  LC_ADDRESS=C
#> [10] LC_TELEPHONE=C             LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C
#>
#> time zone: America/New_York
#> tzcode source: system (glibc)
#>
#> attached base packages:
#> [1] stats     graphics  grDevices utils     datasets  methods   base
#>
#> other attached packages:
#> [1] BiocStyle_2.39.0  readr_2.2.0       reticulate_1.45.0 AnVILVRS_0.99.15  colorout_1.3-2
#>
#> loaded via a namespace (and not attached):
#>  [1] rappdirs_0.3.4       generics_0.1.4       tidyr_1.3.2          RSQLite_2.4.6
#>  [5] lattice_0.22-9       hms_1.1.4            digest_0.6.39        magrittr_2.0.4
#>  [9] evaluate_1.0.5       grid_4.6.0           fastmap_1.2.0        blob_1.3.0
#> [13] jsonlite_2.0.0       Matrix_1.7-5         AnVILGCP_1.5.3       DBI_1.3.0
#> [17] BiocManager_1.30.27  httr_1.4.8           purrr_1.2.1          codetools_0.2-20
#> [21] httr2_1.2.2          cli_3.6.5.9000       rlang_1.1.7          dbplyr_2.5.2
#> [25] bit64_4.6.0-1        withr_3.0.2          cachem_1.1.0         yaml_2.3.12
#> [29] otel_0.2.0           BiocBaseUtils_1.13.0 tools_4.6.0          tzdb_0.5.0
#> [33] memoise_2.0.1        dplyr_1.2.0          filelock_1.0.3       GCPtools_1.1.0
#> [37] curl_7.0.0           vctrs_0.7.2          R6_2.6.1             png_0.1-9
#> [41] lifecycle_1.0.5      BiocFileCache_3.1.0  bit_4.6.0            pkgconfig_2.0.3
#> [45] pillar_1.11.1        rsconnect_1.7.0      glue_1.8.0           Rcpp_1.1.1
#> [49] xfun_0.57            tibble_3.3.1         tidyselect_1.2.1     rstudioapi_0.18.0
#> [53] knitr_1.51           AnVILBase_1.5.1      htmltools_0.5.9      rmarkdown_2.31
#> [57] compiler_4.6.0
```

</details>
