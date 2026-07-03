# Offline test fixtures: pre-populate the cbat4r cache with tiny synthetic
# jsPsych archives so no test needs network access.

# Plugins referenced by the cbat7plus HTML entry points, minus the bundled
# custom plugin (plugin-survey-matrix-likert.js).
FAKE_DIST_PLUGINS <- c(
  "plugin-fullscreen.js",
  "plugin-html-keyboard-response.js",
  "plugin-html-button-response.js",
  "plugin-survey-likert.js",
  "plugin-survey-multi-choice.js",
  "plugin-survey-multi-select.js",
  "plugin-survey-text.js"
)

# Point CBAT4R_CACHE_DIR at a temp dir holding a synthetic jsPsych 8.2.2
# archive (optionally with one plugin removed plus a pre-cached npm fallback)
# and a synthetic 6.3.1 archive.
local_fake_cache <- function(missing_plugin = NULL, env = parent.frame()) {
  cache <- withr::local_tempdir(.local_envir = env)
  withr::local_envvar(CBAT4R_CACHE_DIR = cache, .local_envir = env)

  src <- withr::local_tempdir(.local_envir = env)
  dist <- file.path(src, "dist")
  dir.create(dist)
  for (f in c("jspsych.js", "jspsych.css", FAKE_DIST_PLUGINS)) {
    writeLines(paste("//", f), file.path(dist, f))
  }
  writeLines("// minified, must be skipped", file.path(dist, "jspsych.min.js"))
  writeLines("{}", file.path(dist, "jspsych.js.map"))
  if (!is.null(missing_plugin)) {
    unlink(file.path(dist, missing_plugin))
  }
  dir.create(file.path(cache, "jspsych"), recursive = TRUE)
  zip::zip(file.path(cache, "jspsych", "jspsych-8.2.2.zip"),
           files = "dist", root = src, mode = "cherry-pick")

  legacy_src <- withr::local_tempdir(.local_envir = env)
  legacy_dir <- file.path(legacy_src, "jspsych-6.3.1")
  dir.create(file.path(legacy_dir, "plugins"), recursive = TRUE)
  writeLines("// jspsych 6", file.path(legacy_dir, "jspsych.js"))
  writeLines("// fullscreen", file.path(legacy_dir, "plugins", "jspsych-fullscreen.js"))
  zip::zip(file.path(cache, "jspsych", "jspsych-6.3.1.zip"),
           files = "jspsych-6.3.1", root = legacy_src, mode = "cherry-pick")

  if (!is.null(missing_plugin)) {
    dir.create(file.path(cache, "npm"), recursive = TRUE)
    package <- sub("\\.js$", "", missing_plugin)
    writeLines("// npm fallback", file.path(cache, "npm", paste0(package, "@2.js")))
  }
  cache
}
