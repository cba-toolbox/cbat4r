# CBAT task skeleton generation from bundled template assets.
#
# The text assets of ykunisato/template-jsPsych-task (HTML entry points,
# environment init/run scripts, default task.js, stimuli, custom plugins) are
# bundled with cbat4r, so no template download or checkout is needed. Every
# occurrence of "name_of_repository" in file names and file contents is
# replaced with the requested task name, reproducing the template layout
# exactly. The jsPsych library itself is installed from the official release
# archive (see R/jspsych.R).

PLACEHOLDER <- "name_of_repository"

create_cbat_skeleton <- function(task_name = "task_name",
                                 jsPsych_version = "8.2.2",
                                 output_dir = ".",
                                 add_root_dir = TRUE,
                                 overwrite = FALSE,
                                 task_js = NULL) {
  validate_name(task_name, "task_name")
  major <- validate_cbat_version(jsPsych_version)

  out <- normalizePath(output_dir, mustWork = TRUE)
  if (isTRUE(add_root_dir)) {
    root <- file.path(out, task_name)
    ensure_clean_target(root, overwrite)
  } else {
    root <- out
    ensure_clean_target(file.path(root, task_name), overwrite)
  }
  task_dir <- file.path(root, task_name)
  dir.create(task_dir, showWarnings = FALSE, recursive = TRUE)

  template <- template_path(template_family(jsPsych_version))

  html_files <- character(0)
  for (entry in sort(list.files(template))) {
    source_path <- file.path(template, entry)
    if (!file.exists(source_path) || dir.exists(source_path)) {
      next
    }
    text <- gsub(PLACEHOLDER, task_name, read_text(source_path), fixed = TRUE)
    target <- file.path(root, gsub(PLACEHOLDER, task_name, entry, fixed = TRUE))
    write_text(target, text)
    if (endsWith(target, ".html")) {
      html_files <- c(html_files, target)
    }
  }

  inner_template <- file.path(template, PLACEHOLDER)
  for (entry in sort(list.files(inner_template))) {
    text <- gsub(PLACEHOLDER, task_name,
                 read_text(file.path(inner_template, entry)), fixed = TRUE)
    write_text(file.path(task_dir, entry), text)
  }
  if (!is.null(task_js)) {
    write_text(file.path(task_dir, "task.js"), task_js)
  }

  stimuli_dir <- file.path(task_dir, "stimuli")
  dir.create(stimuli_dir, showWarnings = FALSE, recursive = TRUE)
  stimuli <- template_path("stimuli")
  file.copy(list.files(stimuli, full.names = TRUE), stimuli_dir, overwrite = TRUE)

  jspsych_dir <- install_jspsych(task_dir, jsPsych_version)
  if (major >= 7) {
    pattern <- sprintf('src="%s/jspsych/(plugin-[A-Za-z0-9-]+\\.js)"', task_name)
    referenced <- unlist(lapply(html_files, function(html) {
      matches <- regmatches(read_text(html),
                            gregexpr(pattern, read_text(html)))[[1]]
      sub(pattern, "\\1", matches)
    }))
    ensure_plugins(jspsych_dir, referenced, major)
  }

  invisible(list(
    root = root,
    html_files = html_files,
    task_dir = task_dir,
    jspsych_dir = jspsych_dir,
    stimuli_dir = stimuli_dir
  ))
}

#' Initialize a CBAT task skeleton
#'
#' Creates a new directory for a jsPsych task in the CBAT format: HTML entry
#' points for the Demo, JATOS and CEMA environments, init/run scripts, a
#' starter `task.js`, default stimuli, and the official jsPsych distribution.
#' The template assets are bundled with the package; only the jsPsych library
#' itself is downloaded (once per version, then cached).
#'
#' @param task_name Name of the task, used as the directory name. Must be a
#'   path-safe name (letters, digits, `_`, `-`, `.`).
#' @param jsPsych_version jsPsych version to use (e.g. `"6.3.1"`, `"7.3.4"`,
#'   `"8.2.2"`). Any 7.1+ release works, including releases newer than this
#'   package.
#' @param output_dir Directory in which the task directory is created.
#'   Defaults to the current working directory.
#' @param add_root_dir If `TRUE` (the default), a root directory named
#'   `task_name` is created inside `output_dir` and the HTML entry points and
#'   the `task_name` task directory are placed in it. If `FALSE`, they are
#'   placed directly in `output_dir` instead. Either way, if a directory named
#'   `task_name` already exists at the target location, an error is raised
#'   (unless `overwrite = TRUE`).
#' @param overwrite If `TRUE`, an existing task directory is replaced.
#' @return (Invisibly) a list with the paths of the generated task:
#'   `root`, `html_files`, `task_dir`, `jspsych_dir`, `stimuli_dir`.
#' @examples
#' \dontrun{
#' set_cbat(task_name = "stroop", jsPsych_version = "8.2.2")
#'
#' # Place the HTML files and the task directory directly in "my_study"
#' set_cbat(task_name = "stroop", output_dir = "my_study", add_root_dir = FALSE)
#' }
#' @export
set_cbat <- function(task_name = "task_name",
                     jsPsych_version = "8.2.2",
                     output_dir = ".",
                     add_root_dir = TRUE,
                     overwrite = FALSE) {
  task <- create_cbat_skeleton(
    task_name = task_name,
    jsPsych_version = jsPsych_version,
    output_dir = output_dir,
    add_root_dir = add_root_dir,
    overwrite = overwrite
  )
  message("'", task_name, "' created successfully using jsPsych ", jsPsych_version)
  invisible(task)
}
