test_that("version_family parses and validates version strings", {
  expect_identical(version_family("8.2.2"), 8L)
  expect_identical(version_family("6.3.1"), 6L)
  expect_error(version_family("8.2"), "must look like")
  expect_error(version_family("latest"), "must look like")
  expect_error(version_family(822), "must look like")
})

test_that("validate_cbat_version accepts supported versions", {
  expect_identical(validate_cbat_version("6.3.1"), 6L)
  expect_identical(validate_cbat_version("7.3.4"), 7L)
  expect_identical(validate_cbat_version("8.2.2"), 8L)
  # Releases newer than the package are accepted: the URL is derived from the
  # version string.
  expect_identical(validate_cbat_version("8.9.9"), 8L)
})

test_that("validate_cbat_version rejects unsupported versions", {
  expect_error(validate_cbat_version("6.0.0"), "only supported jsPsych 6")
  expect_error(validate_cbat_version("7.0.0"), "not available")
  expect_error(validate_cbat_version("5.0.3"), "not available")
})

test_that("set_qnr/set_ic require jsPsych 7+", {
  expect_error(validate_qnr_ic_version("6.3.1"), "jsPsych 7 or later")
  expect_identical(validate_qnr_ic_version("8.2.2"), 8L)
})

test_that("template family and jspsych folder follow the version", {
  expect_identical(template_family("6.3.1"), "cbat6")
  expect_identical(template_family("8.2.2"), "cbat7plus")
  expect_identical(jspsych_folder("6.3.1"), "jspsych-6.3.1")
  expect_identical(jspsych_folder("8.2.2"), "jspsych")
})
