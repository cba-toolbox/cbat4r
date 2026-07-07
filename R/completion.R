# Completion code task generation.

# The task.js is a bundled asset (inst/templates/tasks/completion_code.js):
# it takes no user input, and bundling keeps the Japanese text out of the R
# sources (which must be ASCII-only).
completion_code_task_js <- function() {
  read_text(template_path("tasks", "completion_code.js"))
}

#' Create a jsPsych completion-code task
#'
#' Creates a CBAT task skeleton (see [set_cbat()]) whose `task.js` shows a
#' randomly generated participation ID (completion code) at the end of a
#' study, as used on crowdsourcing platforms. The participant is asked to
#' copy the code before finishing; the code is also stored in the trial data.
#' The generated task is the CBAT-format equivalent of
#' <https://github.com/cba-toolbox/completion-code>.
#'
#' @inheritParams set_cbat
#' @return (Invisibly) the same path list as [set_cbat()].
#' @examples
#' \dontrun{
#' set_cc()
#' }
#' @export
set_cc <- function(task_name = "completion_code",
                   jsPsych_version = "8.2.2",
                   output_dir = ".",
                   add_root_dir = TRUE,
                   overwrite = FALSE) {
  validate_qnr_ic_version(jsPsych_version)
  task <- create_cbat_skeleton(
    task_name = task_name,
    jsPsych_version = jsPsych_version,
    output_dir = output_dir,
    add_root_dir = add_root_dir,
    overwrite = overwrite,
    task_js = completion_code_task_js()
  )
  message("'", task_name, "' created successfully using jsPsych ", jsPsych_version)
  invisible(task)
}
