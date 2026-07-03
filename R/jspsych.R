# Download and install official jsPsych distributions.
#
# jsPsych itself is not bundled with cbat4r. Instead, the official release
# archive is downloaded from GitHub once per version and cached, so task
# creation works offline after the first use of a version and new upstream
# releases work without updating cbat4r.

RELEASE_URL_7PLUS <- "https://github.com/jspsych/jsPsych/releases/download/jspsych%%40%s/jspsych.zip"
RELEASE_URL_6 <- "https://github.com/jspsych/jsPsych/releases/download/v%s/jspsych-%s.zip"

# Custom CBAT plugins that are not part of the official jsPsych distribution.
CUSTOM_PLUGINS_7PLUS <- c("plugin-survey-matrix-likert.js")

jspsych_release_url <- function(jsPsych_version) {
  if (jsPsych_version == LEGACY_JSPSYCH_VERSION) {
    sprintf(RELEASE_URL_6, jsPsych_version, jsPsych_version)
  } else {
    sprintf(RELEASE_URL_7PLUS, jsPsych_version)
  }
}

# Cache directory: $CBAT4R_CACHE_DIR, or the R user cache dir.
cbat4r_cache_dir <- function() {
  env <- Sys.getenv("CBAT4R_CACHE_DIR")
  if (nzchar(env)) {
    return(path.expand(env))
  }
  tools::R_user_dir("cbat4r", which = "cache")
}

# Download `url` into the cache at `target` unless already cached.
# The archive is downloaded to a temp file and moved into place atomically.
download_cached <- function(url, target, not_found_hint) {
  if (file.exists(target)) {
    return(target)
  }
  dir.create(dirname(target), showWarnings = FALSE, recursive = TRUE)
  tmp <- tempfile(tmpdir = dirname(target), fileext = ".part")
  on.exit(unlink(tmp), add = TRUE)
  status <- tryCatch(
    utils::download.file(url, tmp, mode = "wb", quiet = TRUE),
    error = function(err) err,
    warning = function(w) w
  )
  if (inherits(status, "condition") || !identical(status, 0L) || !file.exists(tmp)) {
    detail <- if (inherits(status, "condition")) conditionMessage(status) else ""
    if (grepl("404", detail)) {
      stop(url, " was not found. ", not_found_hint, call. = FALSE)
    }
    stop("Failed to download ", url, ". ", detail,
         " Check your network connection; downloads are cached, so network ",
         "access is only required the first time a version is used.",
         call. = FALSE)
  }
  file.rename(tmp, target)
  target
}

# Return the cached jsPsych release archive, downloading it if needed.
fetch_jspsych_archive <- function(jsPsych_version) {
  download_cached(
    jspsych_release_url(jsPsych_version),
    file.path(cbat4r_cache_dir(), "jspsych",
              paste0("jspsych-", jsPsych_version, ".zip")),
    not_found_hint = paste0(
      "jsPsych ", jsPsych_version, " does not exist in the official releases; ",
      "check https://github.com/jspsych/jsPsych/releases for available versions."
    )
  )
}

# Install the official jsPsych distribution into a CBAT task directory.
#
# For jsPsych 7/8 the dist/ files of the release archive are flattened into
# <task_dir>/jspsych/ plus the custom CBAT plugins, matching the
# template-jsPsych-task layout. For 6.3.1 the whole archive is extracted as
# <task_dir>/jspsych-6.3.1/.
install_jspsych <- function(task_dir, jsPsych_version) {
  archive <- fetch_jspsych_archive(jsPsych_version)
  if (jsPsych_version == LEGACY_JSPSYCH_VERSION) {
    install_jspsych_legacy(task_dir, archive)
  } else {
    install_jspsych_7plus(task_dir, archive)
  }
}

install_jspsych_7plus <- function(task_dir, archive) {
  jspsych_dir <- file.path(task_dir, "jspsych")
  dir.create(jspsych_dir, showWarnings = FALSE, recursive = TRUE)
  members <- utils::unzip(archive, list = TRUE)$Name
  wanted <- members[
    grepl("^dist/[^/]+$", members) &
      !grepl("\\.map$", members) &
      !grepl("\\.min\\.", basename(members))
  ]
  if (length(wanted) == 0) {
    stop("No dist/ files found in jsPsych archive ", archive, ".", call. = FALSE)
  }
  exdir <- tempfile("jspsych-dist-")
  on.exit(unlink(exdir, recursive = TRUE), add = TRUE)
  utils::unzip(archive, files = wanted, exdir = exdir)
  file.copy(file.path(exdir, wanted), file.path(jspsych_dir, basename(wanted)),
            overwrite = TRUE)
  for (plugin in CUSTOM_PLUGINS_7PLUS) {
    file.copy(template_path("plugins", plugin), file.path(jspsych_dir, plugin),
              overwrite = TRUE)
  }
  jspsych_dir
}

install_jspsych_legacy <- function(task_dir, archive) {
  utils::unzip(archive, exdir = task_dir)
  jspsych_dir <- file.path(task_dir, paste0("jspsych-", LEGACY_JSPSYCH_VERSION))
  if (!dir.exists(jspsych_dir)) {
    stop("jspsych-", LEGACY_JSPSYCH_VERSION, "/ not found in archive ",
         archive, ".", call. = FALSE)
  }
  jspsych_dir
}

# Make sure every referenced plugin file exists in `jspsych_dir`.
#
# Some release archives are missing plugins that older archives shipped
# (e.g. the jsPsych 8.2.3 archive lacks plugin-survey-multi-choice). Missing
# plugins are fetched individually from the npm registry via jsDelivr, using
# the jsPsych convention that plugin major versions track the core major
# version (core 7 -> plugin 1.x, core 8 -> plugin 2.x).
ensure_plugins <- function(jspsych_dir, plugin_files, core_major) {
  plugin_major <- core_major - 6
  for (plugin_file in sort(unique(plugin_files))) {
    if (file.exists(file.path(jspsych_dir, plugin_file))) {
      next
    }
    package <- sub("\\.js$", "", plugin_file)
    cached <- download_cached(
      sprintf("https://cdn.jsdelivr.net/npm/@jspsych/%s@%d/dist/index.browser.js",
              package, plugin_major),
      file.path(cbat4r_cache_dir(), "npm",
                sprintf("%s@%d.js", package, plugin_major)),
      not_found_hint = paste0(
        "The jsPsych release archive does not contain ", plugin_file,
        " and no @jspsych/", package, " ", plugin_major,
        ".x package exists on npm."
      )
    )
    file.copy(cached, file.path(jspsych_dir, plugin_file), overwrite = TRUE)
  }
  invisible(jspsych_dir)
}
