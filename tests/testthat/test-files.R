test_that("validate_name accepts path-safe names and rejects the rest", {
  expect_identical(validate_name("stroop"), "stroop")
  expect_identical(validate_name("task-1_v2.0"), "task-1_v2.0")
  expect_error(validate_name(""), "non-empty")
  expect_error(validate_name(NULL), "non-empty")
  expect_error(validate_name("a/b"), "path-safe")
  expect_error(validate_name(".."), "path-safe")
  expect_error(validate_name("a b"), "path-safe")
})

test_that("ensure_clean_target refuses to overwrite without overwrite = TRUE", {
  target <- file.path(withr::local_tempdir(), "task")
  dir.create(target)
  expect_error(ensure_clean_target(target, overwrite = FALSE), "already exists")
  ensure_clean_target(target, overwrite = TRUE)
  expect_false(dir.exists(target))
})

test_that("js_str escapes quotes and multibyte text safely", {
  expect_identical(js_str("plain"), "\"plain\"")
  expect_identical(js_str("it's \"quoted\""), "\"it's \\\"quoted\\\"\"")
})

test_that("js_bool accepts logicals and true/false strings", {
  expect_identical(js_bool(TRUE), "true")
  expect_identical(js_bool(FALSE), "false")
  expect_identical(js_bool("true"), "true")
  expect_identical(js_bool("FALSE"), "false")
  expect_error(js_bool("yes"), "Expected TRUE/FALSE")
})
