test_that("set_phaser creates the starter project", {
  out <- withr::local_tempdir()

  root <- set_phaser("game1", "3.80.1", use_rc = FALSE, output_dir = out)

  expect_true(file.exists(file.path(root, "game1.html")))
  expect_true(file.exists(file.path(root, "task.js")))
  expect_true(dir.exists(file.path(root, "assets")))
  expect_match(read_text(file.path(root, "game1.html")), "phaser@3.80.1", fixed = TRUE)
})

test_that("set_phaser with use_rc requires the exercise directory", {
  out <- withr::local_tempdir()
  expect_error(set_phaser("game1", use_rc = TRUE, output_dir = out), "exercise")

  dir.create(file.path(out, "exercise"))
  root <- set_phaser("game1", use_rc = TRUE, output_dir = out)
  expect_identical(basename(dirname(root)), "exercise")
})
