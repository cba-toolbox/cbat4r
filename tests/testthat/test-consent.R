test_that("consent_task_js converts Markdown and escapes dangerous characters", {
  js <- consent_task_js(
    "# Study\n\nText with `backticks` and \"quotes\".",
    ic_question = "Agree?",
    ic_agree_label = "I agree"
  )
  expect_match(js, "type: jsPsychSurveyMultiSelect", fixed = TRUE)
  # markdown adds an id attribute; jsonlite escapes "</" as "<\/".
  expect_match(js, ">Study<\\\\/h1>")
  expect_match(js, 'prompt: "<p><b>Agree?<\\/b><\\/p>"', fixed = TRUE)
  expect_match(js, 'options: ["I agree"]', fixed = TRUE)
  # The preamble is a JSON string literal, so backticks in the source cannot
  # terminate a JS template literal.
  expect_match(js, "preamble: \"", fixed = TRUE)
})

test_that("consent_task_js reads Markdown from a file path", {
  md <- withr::local_tempfile(fileext = ".md", lines = "# From file")
  js <- consent_task_js(md, "Q?", "A")
  expect_match(js, ">From file<\\\\/h1>")
})
