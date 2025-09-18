#' @importFrom reticulate virtualenv_create virtualenv_install virtualenv_exists
#'   py_discover_config
.install_AnVILVRS <- function(envname) {
    python <- tryCatch({
        py_discover_config(
            required_module = "venv", use_environment = envname
        )$python
    }, error = function(e) {
        stop(
            "Python 3.11 is required but was not found on your system.\n",
            "Install Python 3.11 or make it discoverable (e.g., via pyenv).",
            call. = FALSE
        )
    })

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
    message("--> Step 4 of 4: Installing 'vrs_anvil_toolkit' from GitHub...")
    virtualenv_install(
        envname = envname,
        packages = "git+https://github.com/gks-anvil/vrs_anvil_toolkit.git"
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
#' @param force `logical(1)` force re-installation of Zarr requirements
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
