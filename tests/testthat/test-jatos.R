test_that("jatosify packages the study directory into a .jzip", {
  root <- withr::local_tempdir()
  writeLines("<html></html>", file.path(root, "ic.html"))
  writeLines("<html></html>", file.path(root, "task01.html"))
  dir.create(file.path(root, "assets"))
  writeLines("body {}", file.path(root, "assets", "style.css"))
  out <- withr::local_tempdir()

  expect_message(
    jzip <- jatosify("exp01", c("ic.html", "task01.html"), "3.9.0",
                     output_dir = out, root_dir = root),
    "Successfully created"
  )

  expect_identical(basename(jzip), "exp01.jzip")
  entries <- zip::zip_list(jzip)$filename
  expect_true(all(c("ic.html", "task01.html", "exp01.jas",
                    "assets/style.css") %in% entries))
  # The temporary .jas is cleaned up afterwards.
  expect_false(file.exists(file.path(root, "exp01.jas")))
})

test_that("jatosify writes valid JATOS metadata", {
  root <- withr::local_tempdir()
  writeLines("<html></html>", file.path(root, "a.html"))
  out <- withr::local_tempdir()

  suppressMessages(
    jzip <- jatosify("study", "a.html", "3.9.0",
                     study_desc = "desc", output_dir = out, root_dir = root)
  )
  exdir <- withr::local_tempdir()
  zip::unzip(jzip, exdir = exdir)
  jas <- jsonlite::read_json(file.path(exdir, "study.jas"))
  expect_identical(jas$version, "3.9.0")
  expect_identical(jas$data$title, "study")
  expect_identical(jas$data$description, "desc")
  expect_identical(jas$data$componentList[[1]]$htmlFilePath, "a.html")
  expect_identical(jas$data$batchList[[1]]$title, "Default")
})
