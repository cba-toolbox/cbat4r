# Likert questionnaire task generation.

# Build the task.js of a Likert questionnaire. All user-supplied strings are
# emitted through JSON encoding, so quotes and multibyte text are safe; the
# `labels` column is emitted verbatim because it names a JS variable.
likert_task_js <- function(scale, item, instruction, randomize_order = FALSE) {
  if (!is.data.frame(item) || !all(c("prompt", "name") %in% names(item))) {
    stop("item must be a data frame with at least 'prompt' and 'name' columns.",
         call. = FALSE)
  }
  required <- if ("required" %in% names(item)) item$required else rep(TRUE, nrow(item))
  labels <- if ("labels" %in% names(item)) item$labels else rep("scale", nrow(item))

  questions <- vapply(seq_len(nrow(item)), function(i) {
    paste0(
      "    {prompt: ", js_str(item$prompt[i]),
      ", required: ", js_bool(required[i]),
      ", name: ", js_str(item$name[i]),
      ", labels: ", labels[i], "},"
    )
  }, character(1))

  paste(c(
    "/* scale settings */",
    paste0("const scale = ",
           as.character(jsonlite::toJSON(as.character(scale), pretty = 2)), ";"),
    "",
    "/* questionnaire settings */",
    "const likert_page = {",
    "  type: jsPsychSurveyLikert,",
    "  questions: [",
    questions,
    "  ],",
    paste0("  randomize_question_order: ", js_bool(randomize_order), ","),
    paste0("  preamble: ", js_str(instruction), ","),
    "  button_label: '\u6b21\u3078',",
    "  on_load: function() {",
    "    const style = document.createElement('style');",
    "    style.innerHTML = `",
    "      .jspsych-survey-likert-statement,",
    "      .jspsych-survey-likert-preamble,",
    "      .jspsych-survey-likert-label,",
    "      .jspsych-survey-likert-question,",
    "      .jspsych-survey-likert-text { text-align: left !important; }",
    "      .jspsych-survey-likert-question {",
    "        justify-content: flex-start !important;",
    "        align-items: flex-start !important;",
    "      }",
    "    `;",
    "    document.head.appendChild(style);",
    "  }",
    "};",
    "",
    "/* timeline */",
    "const timeline = [likert_page];",
    ""
  ), collapse = "\n")
}

#' Create a jsPsych Likert questionnaire task
#'
#' Creates a CBAT task skeleton (see [set_cbat()]) whose `task.js` presents
#' the given items with the `jsPsychSurveyLikert` plugin.
#'
#' @inheritParams set_cbat
#' @param scale Character vector of scale labels
#'   (e.g. `c("Strongly Disagree", ..., "Strongly Agree")`).
#' @param item Data frame of questionnaire items with columns `prompt`
#'   (question text) and `name` (variable name); optionally `required`
#'   (`TRUE`/`FALSE` or `"true"`/`"false"`, default `TRUE`) and `labels`
#'   (name of the JS variable holding the scale labels, default `"scale"`).
#' @param instruction Instruction or preamble text displayed above the items.
#' @param randomize_order Whether to randomize the item order
#'   (`TRUE`/`FALSE` or `"true"`/`"false"`).
#' @return (Invisibly) the same path list as [set_cbat()].
#' @examples
#' \dontrun{
#' items <- data.frame(
#'   prompt = c("I feel happy.", "I feel energetic."),
#'   name = c("happy", "energetic")
#' )
#' set_qnr(
#'   task_name = "mood_survey",
#'   scale = c("Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"),
#'   item = items,
#'   instruction = "Please answer the following questions."
#' )
#' }
#' @export
set_qnr <- function(task_name = "scale_name",
                    scale,
                    item,
                    instruction = "",
                    randomize_order = FALSE,
                    jsPsych_version = "8.2.2",
                    output_dir = ".",
                    add_root_dir = TRUE,
                    overwrite = FALSE) {
  validate_qnr_ic_version(jsPsych_version)
  if (missing(scale)) stop("scale is required.", call. = FALSE)
  if (missing(item)) stop("item is required.", call. = FALSE)
  task <- create_cbat_skeleton(
    task_name = task_name,
    jsPsych_version = jsPsych_version,
    output_dir = output_dir,
    add_root_dir = add_root_dir,
    overwrite = overwrite,
    task_js = likert_task_js(scale, item, instruction, randomize_order)
  )
  message("'", task_name, "' created successfully using jsPsych ", jsPsych_version)
  invisible(task)
}
