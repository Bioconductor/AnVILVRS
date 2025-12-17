#' @importFrom reticulate virtualenv_create virtualenv_install virtualenv_exists
#'   py_discover_config
#' @importFrom BiocBaseUtils askUserYesNo
.install_AnVILVRS <- function(envname) {

    # 1. Prevent "User site-packages are not visible" error
    pipuser <- Sys.getenv("PIP_USER")
    Sys.unsetenv("PIP_USER")
    # 2. Prevent reticulate from locking onto the wrong system Python
    ret_python <- Sys.getenv("RETICULATE_PYTHON")
    Sys.unsetenv("RETICULATE_PYTHON")
    # 3. Re-set AnVIL environment variables
    on.exit(
        Sys.setenv(
            PIP_USER = pipuser,
            RETICULATE_PYTHON = ret_python
        )
    )

    python <- tryCatch({
        # Use reticulate's function to find a specific Python version
        py_discover_config(use_environment = envname)$python
    }, error = function(e) {
        stop(
          "Python is required but was not found on your system.\n",
          "Install Python 3.11 with:\n",
          "    reticulate::install_python(\"3.11:latest\")",
          call. = FALSE
        )
    })

    py_ver <- system2(python, "--version", stdout = TRUE)
    has311 <- py_ver |>  grepl("^Python 3\\.11", x = _)

    if (!has311 && askUserYesNo("Do you want to install Python '3.11:latest'?"))
        python <- reticulate::install_python(version = "3.11:latest")

    # 1. Create the virtual environment using the discovered Python 3.11
    if (!virtualenv_exists(envname))
        virtualenv_create(envname = envname, python = python)

    # 2. Downgrade tools for firecloud
    message("--> Step 1 of 4: Downgrading build tools for 'firecloud'...")
    virtualenv_install(
        envname = envname, packages = c("setuptools<58", "pip<23.1")
    )

    # 3. Install firecloud
    message("--> Step 2 of 4: Installing 'firecloud'...")
    virtualenv_install(
        envname = envname, packages = c("firecloud==0.16.38")
    )

    # 4. Upgrade tools for the main package
    message("--> Step 3 of 4: Upgrading build tools...")
    virtualenv_install(
        envname = envname, packages = c("setuptools", "pip"),
        pip_options = "--upgrade"
    )

    # 5. Install vrs_anvil_toolkit
    message("--> Step 4 of 4: Installing 'vrs_anvil_toolkit'")
    virtualenv_install(
        envname = envname, packages = "vrs-anvil-toolkit"
    )

    # 6. Install GA4GH VRS and plugin_system
    virtualenv_install(
        envname = envname,
        packages = c("ga4gh.vrs[extras]", "plugin_system")
    )

}

#' @rdname install_AnVILVRS
#'
#' @title Install AnVILVRS Python Environment
#'
#' @param envname `character(1)` virtual environment in which to
#'     install the python zarr module.
#'
#' @param force `logical(1)` force re-installation of AnVILVRS requirements
#'
#' @importFrom reticulate virtualenv_list use_virtualenv
#' @importFrom BiocBaseUtils isScalarCharacter
#'
#' @return Reference to the python module, invisibly.
#'
#' @export
install_AnVILVRS <-
    function(envname = "vrs_env", force = FALSE)
{
    stopifnot(isScalarCharacter(envname))
    is_windows <- identical(.Platform$OS.type, "windows")
    is_osx <- Sys.info()["sysname"] == "Darwin"
    is_linux <- identical(tolower(Sys.info()[["sysname"]]), "linux")
    if (!is_windows && !is_osx && !is_linux) {
        stop(
            "Unable to install 'AnVILVRS' on this platform. ",
            "Binary installation is available for Windows, macOS, and Linux"
        )
    }

    # Check if the environment exists or if installation is forced
    if (!envname %in% virtualenv_list() || force) {
        message("Creating Python virtual environment '", envname, "'...")
        .install_AnVILVRS(envname)
        message("Environment '", envname, "' created successfully.")
    } else {
        message("Using existing virtual environment '", envname, "'.")
    }

    # Point reticulate to the environment for the current session
    use_virtualenv(virtualenv = envname, required = TRUE)

    # A helper function that likely imports and returns the module
    message(
        "Installation complete. The 'vrs_env' environment is ready to use."
    )

    invisible(.anvilvrs())
}
