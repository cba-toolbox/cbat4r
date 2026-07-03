# Filesystem helpers.

# Validate that a task/game name is a safe single path component.
validate_name <- function(name, label = "name") {
  if (!is.character(name) || length(name) != 1 || is.na(name) || !nzchar(name)) {
    stop(label, " must be a non-empty string.", call. = FALSE)
  }
  if (name %in% c(".", "..") || !grepl("^[A-Za-z0-9_.-]+$", name)) {
    stop(label, " must be path-safe: ", deparse(name), call. = FALSE)
  }
  name
}

# Refuse to overwrite an existing target unless overwrite = TRUE.
ensure_clean_target <- function(path, overwrite) {
  if (file.exists(path) || dir.exists(path)) {
    if (!isTRUE(overwrite)) {
      stop(path, " already exists. Use overwrite = TRUE to replace it.", call. = FALSE)
    }
    unlink(path, recursive = TRUE, force = TRUE)
  }
  invisible(path)
}

# Write UTF-8 text to a file, creating parent directories as needed.
write_text <- function(path, text) {
  dir.create(dirname(path), showWarnings = FALSE, recursive = TRUE)
  con <- file(path, open = "wb")
  on.exit(close(con))
  writeLines(enc2utf8(text), con, sep = "\n", useBytes = TRUE)
  invisible(path)
}

# Path to a bundled template asset.
template_path <- function(...) {
  path <- system.file("templates", ..., package = "cbat4r", mustWork = FALSE)
  if (!nzchar(path)) {
    stop("Bundled template asset not found: ",
         file.path(...), ". The cbat4r installation looks broken.", call. = FALSE)
  }
  path
}

read_text <- function(path) {
  paste(readLines(path, encoding = "UTF-8", warn = FALSE), collapse = "\n")
}

# Encode a single string as a JavaScript string literal (with quotes).
js_str <- function(x) {
  as.character(jsonlite::toJSON(as.character(x)[1], auto_unbox = TRUE))
}

# Interpret TRUE/FALSE, "true"/"false", "TRUE"/"FALSE" as a JS boolean literal.
js_bool <- function(value) {
  if (is.logical(value) && length(value) == 1 && !is.na(value)) {
    return(if (value) "true" else "false")
  }
  if (is.character(value) && length(value) == 1) {
    lowered <- tolower(trimws(value))
    if (lowered %in% c("true", "false")) {
      return(lowered)
    }
  }
  stop("Expected TRUE/FALSE (or \"true\"/\"false\"), got ", deparse(value), ".",
       call. = FALSE)
}
