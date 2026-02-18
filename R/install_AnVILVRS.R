#' @importFrom reticulate virtualenv_create virtualenv_install virtualenv_exists
#'   py_discover_config
#' @importFrom BiocBaseUtils askUserYesNo
.install_AnVILVRS <- function(envname) {

    # 1. Prevent "User site-packages are not visible" error
    pipuser <- Sys.getenv("PIP_USER")
    Sys.unsetenv("PIP_USER")
    # 2a. Re-set PIP_USER environment variable
    on.exit(Sys.setenv(PIP_USER = pipuser))
    # 3. Prevent reticulate from locking onto the wrong system Python
    ret_python <- Sys.getenv("RETICULATE_PYTHON")
    # 3a. Re-set RETICULATE_PYTHON environment variable
    if (nzchar(ret_python)) {
        Sys.unsetenv("RETICULATE_PYTHON")
        on.exit(
            Sys.setenv(
                RETICULATE_PYTHON = ret_python
            ),
            add = TRUE
        )
    }

    python3.11 <- reticulate::virtualenv_starter("<=3.11")
    prompt <- "Do you want to install Python '3.11:latest'?"

    if (is.null(python3.11) && askUserYesNo(prompt))
        python3.11 <- reticulate::install_python(version = "3.11:latest")
    else if (is.null(python3.11))
        stop(
            "Python 3.11 is required but was not found with ",
            "'virtualenv_starter(\"<=3.11\")'.\n",
            "To install, use:\n",
            "    reticulate::install_python(\"3.11:latest\")",
            call. = FALSE
        )

    if (!virtualenv_exists(envname))
        virtualenv_create(envname = envname, python = python3.11)

    message("--> Step 1 of 5: Downgrading build tools for 'firecloud'...")
    virtualenv_install(
        envname = envname, packages = c("setuptools<58", "pip<23.1")
    )

    message("--> Step 2 of 5: Installing 'firecloud'...")
    virtualenv_install(
        envname = envname, packages = c("firecloud==0.16.38")
    )

    message("--> Step 3 of 5: Upgrading build tools...")
    virtualenv_install(
        envname = envname, packages = c("setuptools", "pip"),
        pip_options = "--upgrade"
    )

    message("--> Step 4 of 5: Installing 'vrs_anvil_toolkit'")
    virtualenv_install(
        envname = envname, packages = "vrs-anvil-toolkit"
    )

    message(
        "--> Step 5 of 5: Installing 'ga4gh.vrs[extras]', 'plugin_system', ",
        "and 'biocommons.seqrepo'"
    )
    virtualenv_install(
        envname = envname,
        packages = c("ga4gh.vrs[extras]", "plugin_system", "biocommons.seqrepo")
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
#' @examplesIf interactive()
#' library(reticulate)
#' has_vrs_env <- virtualenv_exists("vrs_env")
#' if (!has_vrs_env)
#'     install_AnVILVRS(envname = "vrs_env")
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
