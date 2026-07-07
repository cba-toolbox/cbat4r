# Informed consent task generation.

# Build the task.js of an informed-consent page. The Markdown source is
# converted to an HTML fragment and embedded via JSON encoding, so quotes and
# backticks cannot break the generated JavaScript.
consent_task_js <- function(ic_markdown, ic_question, ic_agree_label) {
  is_path <- !grepl("\n", ic_markdown, fixed = TRUE) && file.exists(ic_markdown)
  md_text <- if (is_path) read_text(ic_markdown) else ic_markdown
  html_content <- markdown::markdownToHTML(text = md_text, fragment.only = TRUE)
  paste(c(
    "/* informed consent settings */",
    "const ic = {",
    "  type: jsPsychSurveyMultiSelect,",
    paste0("  preamble: ", js_str(html_content), ","),
    "  questions: [{",
    paste0("    prompt: ", js_str(paste0("<p><b>", ic_question, "</b></p>")), ","),
    paste0("    options: [", js_str(ic_agree_label), "],"),
    "    required: true,",
    "    name: 'approval'",
    "  }],",
    "  button_label: '\u6b21\u3078',",
    "  on_load: function() {",
    "    const style = document.createElement('style');",
    "    style.innerHTML = `",
    "      .jspsych-survey-multi-select-preamble { text-align: left; max-width: 800px; margin: 0 auto; line-height: 1.6; }",
    "      .jspsych-survey-multi-select-question { margin-top: 20px; }",
    "    `;",
    "    document.head.appendChild(style);",
    "  }",
    "};",
    "",
    "/* timeline */",
    "const timeline = [ic];",
    ""
  ), collapse = "\n")
}

#' Create a jsPsych informed-consent task
#'
#' Creates a CBAT task skeleton (see [set_cbat()]) whose `task.js` shows an
#' informed-consent document (converted from Markdown) and requires the
#' participant to check an agreement box before continuing.
#'
#' @inheritParams set_cbat
#' @param ic_markdown Consent text in Markdown format, or a path to a `.md`
#'   file.
#' @param ic_question Consent question shown below the document.
#' @param ic_agree_label Label of the agreement checkbox.
#' @return (Invisibly) the same path list as [set_cbat()].
#' @examples
#' \dontrun{
#' set_ic(
#'   task_name = "consent",
#'   ic_markdown = "# Study information\nYour participation is voluntary."
#' )
#' }
#' @export
set_ic <- function(task_name = "ic",
                   ic_markdown,
                   ic_question = "Do you agree to participate in the research after reading and understanding the above information?",
                   ic_agree_label = "I have read and understood the information and agree to participate in the research.",
                   jsPsych_version = "8.2.2",
                   output_dir = ".",
                   add_root_dir = TRUE,
                   overwrite = FALSE) {
  validate_qnr_ic_version(jsPsych_version)
  if (missing(ic_markdown) || !is.character(ic_markdown) || !nzchar(ic_markdown)) {
    stop("ic_markdown is required.", call. = FALSE)
  }
  task <- create_cbat_skeleton(
    task_name = task_name,
    jsPsych_version = jsPsych_version,
    output_dir = output_dir,
    add_root_dir = add_root_dir,
    overwrite = overwrite,
    task_js = consent_task_js(ic_markdown, ic_question, ic_agree_label)
  )
  message("'", task_name, "' created successfully using jsPsych ", jsPsych_version)
  invisible(task)
}
