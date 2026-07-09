test_that("set_cbat creates the CBAT layout for jsPsych 8", {
  local_fake_cache()
  out <- withr::local_tempdir()

  expect_message(set_cbat("stroop", "8.2.2", output_dir = out), "created successfully")

  root <- file.path(out, "stroop")
  expect_true(file.exists(file.path(root, "stroop.html")))
  expect_true(file.exists(file.path(root, "demo_stroop.html")))
  expect_true(file.exists(file.path(root, "cema_stroop.html")))
  expect_true(file.exists(file.path(root, "README_stroop.md")))
  task_dir <- file.path(root, "stroop")
  expect_true(file.exists(file.path(task_dir, "task.js")))
  expect_true(file.exists(file.path(task_dir, "demo_jspsych_init.js")))
  expect_true(file.exists(file.path(task_dir, "jatos_jspsych_run.js")))
  expect_true(file.exists(file.path(task_dir, "stimuli", "reward.jpeg")))

  # jsPsych dist is flattened, without minified/map files, plus the bundled
  # custom plugin.
  jspsych_dir <- file.path(task_dir, "jspsych")
  expect_true(file.exists(file.path(jspsych_dir, "jspsych.js")))
  expect_true(file.exists(file.path(jspsych_dir, "plugin-survey-matrix-likert.js")))
  expect_false(file.exists(file.path(jspsych_dir, "jspsych.min.js")))
  expect_false(file.exists(file.path(jspsych_dir, "jspsych.js.map")))

  # The placeholder is fully replaced in file names and contents.
  html <- read_text(file.path(root, "stroop.html"))
  expect_match(html, "stroop/jspsych/jspsych.js", fixed = TRUE)
  expect_no_match(html, "name_of_repository", fixed = TRUE)

  # The mobile stylesheet is bundled and linked from every HTML entry point.
  expect_true(file.exists(file.path(task_dir, "jspsych-mobile.css")))
  for (h in c("stroop.html", "demo_stroop.html", "cema_stroop.html")) {
    entry <- read_text(file.path(root, h))
    expect_match(entry, "stroop/jspsych-mobile.css", fixed = TRUE)
  }
})

test_that("set_cbat creates the legacy layout for jsPsych 6.3.1", {
  local_fake_cache()
  out <- withr::local_tempdir()

  set_cbat("legacy_task", "6.3.1", output_dir = out)

  root <- file.path(out, "legacy_task")
  task_dir <- file.path(root, "legacy_task")
  expect_true(file.exists(file.path(root, "legacy_task.html")))
  expect_false(file.exists(file.path(root, "cema_legacy_task.html")))
  expect_true(file.exists(file.path(task_dir, "jspsych-6.3.1", "jspsych.js")))
  expect_true(file.exists(file.path(task_dir, "demo_fullscreen.js")))

  # The mobile stylesheet is bundled and linked in the legacy layout too.
  expect_true(file.exists(file.path(task_dir, "jspsych-mobile.css")))
  html <- read_text(file.path(root, "legacy_task.html"))
  expect_match(html, "legacy_task/jspsych-mobile.css", fixed = TRUE)
})

test_that("set_cbat refuses to overwrite unless asked", {
  local_fake_cache()
  out <- withr::local_tempdir()

  set_cbat("stroop", "8.2.2", output_dir = out)
  expect_error(set_cbat("stroop", "8.2.2", output_dir = out), "already exists")
  expect_message(set_cbat("stroop", "8.2.2", output_dir = out, overwrite = TRUE),
                 "created successfully")
})

test_that("add_root_dir = FALSE places the files directly in output_dir", {
  local_fake_cache()
  out <- withr::local_tempdir()

  task <- set_cbat("stroop", "8.2.2", output_dir = out, add_root_dir = FALSE)

  expect_true(file.exists(file.path(out, "stroop.html")))
  expect_true(file.exists(file.path(out, "demo_stroop.html")))
  expect_true(file.exists(file.path(out, "stroop", "task.js")))
  expect_false(dir.exists(file.path(out, "stroop", "stroop")))
  expect_equal(task$root, normalizePath(out))
  expect_equal(task$task_dir, file.path(normalizePath(out), "stroop"))
})

test_that("add_root_dir = FALSE errors if the task directory already exists", {
  local_fake_cache()
  out <- withr::local_tempdir()

  dir.create(file.path(out, "stroop"))
  expect_error(set_cbat("stroop", "8.2.2", output_dir = out, add_root_dir = FALSE),
               "already exists")

  expect_message(set_cbat("stroop", "8.2.2", output_dir = out,
                          add_root_dir = FALSE, overwrite = TRUE),
                 "created successfully")
  expect_true(file.exists(file.path(out, "stroop", "task.js")))
})

test_that("missing plugins are filled from the npm cache", {
  local_fake_cache(missing_plugin = "plugin-survey-text.js")
  out <- withr::local_tempdir()

  set_cbat("filler", "8.2.2", output_dir = out)

  plugin <- file.path(out, "filler", "filler", "jspsych", "plugin-survey-text.js")
  expect_true(file.exists(plugin))
  expect_match(read_text(plugin), "npm fallback", fixed = TRUE)
})

test_that("set_qnr and set_ic write their generated task.js", {
  local_fake_cache()
  out <- withr::local_tempdir()

  set_qnr(
    task_name = "qnr",
    scale = c("no", "yes"),
    item = data.frame(prompt = "Are you fine?", name = "fine"),
    instruction = "Answer.",
    output_dir = out
  )
  qnr_js <- read_text(file.path(out, "qnr", "qnr", "task.js"))
  expect_match(qnr_js, "jsPsychSurveyLikert", fixed = TRUE)

  set_ic(task_name = "ic", ic_markdown = "# Info", output_dir = out)
  ic_js <- read_text(file.path(out, "ic", "ic", "task.js"))
  expect_match(ic_js, "jsPsychSurveyMultiSelect", fixed = TRUE)

  expect_error(set_qnr(task_name = "q6", scale = c("a"),
                       item = data.frame(prompt = "p", name = "n"),
                       jsPsych_version = "6.3.1", output_dir = out),
               "jsPsych 7 or later")
})

test_that("set_cbat validates the task name", {
  local_fake_cache()
  out <- withr::local_tempdir()
  expect_error(set_cbat("bad/name", "8.2.2", output_dir = out), "path-safe")
})
