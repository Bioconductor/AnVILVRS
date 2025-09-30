# AnVILVRS

The `AnVILVRS` R package provides tools to work with genomic variation data,
leveraging the GA4GH Variant Representation Specification (VRS). It serves as
an R interface to the `vrs_anvil_toolkit` Python package, allowing users to
translate variant identifiers into VRS seamlessly within the R environment.

## Installation

First, install the `AnVILVRS` package from GitHub:

```r
if (!requireNamespace("devtools", quietly = TRUE))
    install.packages("devtools")
devtools::install_github("Bioconductor/AnVILVRS")
```

Next, set up the necessary Python environment. The package provides a function
to handle the installation of the required Python dependencies in a
`reticulate` virtual environment.

```r
library(AnVILVRS)
install_AnVILVRS()
```

This will create a Python virtual environment named `vrs_env` and install all
the necessary components.

## Usage

Before using the package functions, load the virtual environment:

```r
library(reticulate)
use_virtualenv("vrs_env", required = TRUE)
```

Here is an example of how to translate a variant in gnomAD format to a VRS
Allele ID:

```r
library(AnVILVRS)
# Translate a gnomad variant to a VRS ID
get_vrs_id("chr7-87509329-A-G", "gnomad")
```

The package also supports other formats like `spdi`, `hgvs`, and `beacon`.

For more information on the available functions, please refer to the package
documentation.

