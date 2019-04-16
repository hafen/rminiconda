#' Install miniconda
#'
#' Download the miniconda installer and run it.
#'
#' @param version The major version number of Python (2 or 3). The latest version of the specified major version will be installed.
#' @param path Where to place the miniconda installation
#' @return \code{NULL} (miniconda is installed to a system directory).
#' @importFrom utils download.file
#' @export
install_miniconda <- function(version = 3, path = file.path(path.expand("~"), "rminiconda")) {
  ## Work in a temporary directory and move back to original wd on exit
  owd <- setwd(tempdir())
  on.exit(setwd(owd), add = TRUE)

  ## Check version
  # For now, it's just latest Python 2 or 3.
  # It could be exact Python version but not now because we would
  # have to map exact conda versions to exact Python versions.
  # https://repo.anaconda.com/miniconda/
  if (!version %in% c(2, 3))
    stop("'version' must be 2 or 3.")

  base_url <- "https://repo.anaconda.com/miniconda/"
  arch <- paste0("x86", ifelse(.Machine$sizeof.pointer == 8, "_64", ""))

  success <- FALSE
  if (is_windows()) {
    inst_file <- sprintf("Miniconda%s-latest-Windows-%s.exe", version, arch)
    utils::download.file(paste0(base_url, inst_file), inst_file)
    # install...
    success <- TRUE
  } else if (is_osx()) {
    inst_file <- sprintf("Miniconda%s-latest-MacOSX-%s.sh", version, arch)
    utils::download.file(paste0(base_url, inst_file), inst_file)
    # install...
    success <- TRUE
  } else if (is_linux()) {
    inst_file <- sprintf("Miniconda%s-latest-Linux-%s.sh", version, arch)
    utils::download.file(paste0(base_url, inst_file), inst_file)
    # install...
    success <- TRUE
  } else {
    # Unsupported platform, like Solaris
    message("Sorry, this platform is not supported.")
    return(invisible())
  }
  if (!success)
    stop("Unable to install miniconda...")
  message("miniconda has been installed to ... (additional messages...)")
  invisible()
}

# find_miniconda <- function() {
# }

# remove_miniconda <- function() {
# }

is_windows <- function() .Platform$OS.type == "windows"
is_osx     <- function() Sys.info()[["sysname"]] == "Darwin"
is_linux   <- function() Sys.info()[["sysname"]] == "Linux"
