#' Install miniconda
#'
#' Download the miniconda installer and run it.
#'
#' @param version The major version number of Python (2 or 3). The latest version of the specified major version will be installed.
#' @param path The base directory where all "rminiconda" miniconda installations are located (see \code{\link{get_miniconda_path}} for more information).
#' @param name The name of the installation.
#' @return \code{NULL} (miniconda is installed to a system directory).
#' @details The \code{name} can be thought of as a project name with which to associate your miniconda installation. The miniconda installation will go in \code{{path}/{name}}. You can have different installations for different purposes.
#' @importFrom utils download.file
#' @export
install_miniconda <- function(version = 3,
  path = get_miniconda_path(),
  name = "general") {

  ## Set up paths
  dest_path <- normalizePath(file.path(path, name), mustWork = FALSE)
  if (dir.exists(dest_path))
    stop("An installation already exists at:\n", dest_path, "\n",
      "If you'd like to install a fresh version, first run:\n",
      paste0("remove_miniconda(path = \"", path, "\", name = \"", name, "\")"))

  message("Using path for conda installation:\n  ", dest_path)

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

  if (is_windows()) {
    inst_file <- sprintf("Miniconda%s-latest-Windows-%s.exe", version, arch)
    inst_cmd <- inst_file
    inst_args <- sprintf(" /InstallationType=JustMe /RegisterPython=0 /S /D=%s",
      dest_path)
  } else if (is_osx()) {
    inst_file <- sprintf("Miniconda%s-latest-MacOSX-%s.sh", version, arch)
    inst_cmd <- "bash"
    inst_args <- sprintf(" %s -b -p \"%s\"", inst_file, dest_path)
  } else if (is_linux()) {
    inst_file <- sprintf("Miniconda%s-latest-Linux-%s.sh", version, arch)
    inst_cmd <- "bash"
    inst_args <- sprintf(" %s -b -p %s", inst_file, dest_path)
  } else {
    # Unsupported platform, like Solaris
    message("Sorry, this platform is not supported.")
    return(invisible())
  }
  ## Download
  message("Installing isolated miniconda distribution...")
  message("Source: ", paste0(base_url, inst_file))
  message("Destination: ", dest_path)
  dl_res <- utils::download.file(paste0(base_url, inst_file), inst_file,
    mode = "wb")
  if (dl_res != 0 || !file.exists(inst_file))
    stop("There was an issue downloading the file\n",
      paste0(base_url, inst_file),
      "\n",
      "Please check your version number.",
      call. = FALSE)

  message("By installing, you accept the Conda license:")
  message("  https://conda.io/en/latest/license.html")

  ## Install
  inst_res <- system2(inst_cmd, inst_args)
  if (inst_res != 0)
    stop("There was a problem installing miniconda.", call. = FALSE)

  ## Check installation
  python_bin <- find_miniconda_python(name, path)

  res <- try(system2(python_bin, " -c \"print('hello world')\"",
    stdout = TRUE, stderr = TRUE), silent = TRUE)
  if (res != "hello world")
    stop("Installation was not successful.", call. = FALSE)

  writeLines(c(version, inst_file), file.path(dest_path, "info.txt"))

  message("miniconda installation successful!")
  invisible(TRUE)
}

#' Get the path for where all "rminiconda" miniconda installations are located
#' @details The goal of rminiconda is to provide isolated installations of Python via miniconda that the user doesn't have to worry about. Because of this, the intention is to have a default location for the installations that it outside the user's view. By default, the path will be the installed "rminiconda" package directory, if writable by the user. If not, the "fallback" path will be a "rminiconda" directory in the user's home directory. If you would like to use a different directory for your rminiconda installations, set an environment variable \code{R_MINICONDA_PATH}.
#' @export
get_miniconda_path <- function() {
  path <- Sys.getenv("R_MINICONDA_PATH")
  if (path != "" && dir.exists(path))
    return (path)

  path <- file.path(system.file(package = "rminiconda"), "rminiconda")
  if (file.access(path, mode = 2) == 0) # writeable
    return (path)

  path <- file.path(path.expand("~"), "rminiconda")
  if (!dir.exists(path))
    dir.create(path)

  path
}

#' Find the python binary executable for an rminiconda installation
#' @param name The name of the miniconda installation.
#' @param path The base directory where all "rminiconda" miniconda installations are located.
#' @export
find_miniconda_python <- function(
  name = "general", path = get_miniconda_path()) {
  if (is_windows()) {
    normalizePath(file.path(path, name, "python.exe"))
  } else {
    normalizePath(file.path(path, name, "bin", "python"))
  }
}

#' Find the pip binary executable for an rminiconda installation
#' @param name The name of the miniconda installation.
#' @param path The base directory where all "rminiconda" miniconda installations are located.
#' @export
find_miniconda_pip <- function(
  name = "general", path = get_miniconda_path()) {
  normalizePath(file.path(path, name, "bin", "pip"))
}

#' Remove an "rminiconda" miniconda installation
#' @param name The name of the miniconda installation.
#' @param path The base directory where all "rminiconda" miniconda installations are located.
#' @export
remove_miniconda <- function(
  name = "general", path = get_miniconda_path()) {
  pth <- file.path(path, name)
  if (!dir.exists(pth)) {
    message("There is not a miniconda installation at:\n", pth)
    return (invisible(FALSE))
  }

  if (!file.exists(file.path(pth, "bin", "python"))) {
    message("The supplied path does not contain a miniconda installation:\n",
      pth)
    return (invisible(FALSE))
  }

  message(
    "You are about to remove the following directory:\n  ",
    pth, "\n",
    "Are you sure you want to do this? (Y/n) ")
  ans <- readline()
  if (ans == "Y" || ans == "") {
    message("Removing miniconda installation, '", name, "'...")
    unlink(pth, recursive = TRUE)
  }
}

is_windows <- function() .Platform$OS.type == "windows"
is_osx     <- function() Sys.info()[["sysname"]] == "Darwin"
is_linux   <- function() Sys.info()[["sysname"]] == "Linux"
