test_that("completion_code_task_js loads the bundled completion-code script", {
  js <- completion_code_task_js()
  expect_match(js, "jsPsych.randomization.randomID(10)", fixed = TRUE)
  expect_match(js, "type: jsPsychHtmlButtonResponse", fixed = TRUE)
  expect_match(js, "data: {id: id_no}", fixed = TRUE)
  expect_match(js, "const timeline = [finish];", fixed = TRUE)
})

test_that("set_cc creates a completion-code task without arguments", {
  local_fake_cache()
  withr::local_dir(withr::local_tempdir())

  expect_message(set_cc(), "created successfully")

  task_js <- read_text(file.path("completion_code", "completion_code", "task.js"))
  expect_match(task_js, "jsPsychHtmlButtonResponse", fixed = TRUE)
  # Every entry point loads the html-button-response plugin used by the
  # completion-code trial.
  for (html_file in c("completion_code.html", "demo_completion_code.html",
                      "cema_completion_code.html")) {
    html <- read_text(file.path("completion_code", html_file))
    expect_match(html, "plugin-html-button-response.js", fixed = TRUE)
  }
})

test_that("set_cc requires jsPsych 7+ and respects overwrite", {
  local_fake_cache()
  out <- withr::local_tempdir()

  expect_error(set_cc(jsPsych_version = "6.3.1", output_dir = out),
               "jsPsych 7 or later")

  set_cc(output_dir = out)
  expect_error(set_cc(output_dir = out), "already exists")
  expect_message(set_cc(output_dir = out, overwrite = TRUE), "created successfully")
})
