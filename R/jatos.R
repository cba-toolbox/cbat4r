# JATOS packaging.

#' Create a JATOS .jzip study archive
#'
#' Writes the JATOS study metadata (`.jas`) for the given HTML components and
#' packages it together with everything under `root_dir` into a `.jzip` file
#' that can be imported into JATOS. The temporary `.jas` file is removed
#' afterwards.
#'
#' @param study_title Title of the study, used for the `.jzip` filename and
#'   the study directory name in JATOS.
#' @param html_file_list Character vector of HTML filenames used as JATOS
#'   components (order is preserved).
#' @param JATOS_version JATOS study version (e.g. `"3.9.0"`).
#' @param study_desc Short description of the study.
#' @param study_comment Comments about the study.
#' @param output_dir Output directory for the `.jzip` file.
#' @param root_dir Directory whose contents are packaged. Defaults to the
#'   current working directory.
#' @return The path of the created `.jzip` file.
#' @examples
#' \dontrun{
#' jatosify("exp01", c("ic.html", "age_gender.html", "task01.html"), "3.9.0")
#' }
#' @export
jatosify <- function(study_title,
                     html_file_list,
                     JATOS_version,
                     study_desc = "",
                     study_comment = "",
                     output_dir = ".",
                     root_dir = ".") {
  root <- normalizePath(root_dir, mustWork = TRUE)
  dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)
  output <- normalizePath(output_dir, mustWork = TRUE)

  component_list <- lapply(html_file_list, function(html_file) {
    list(
      uuid = uuid::UUIDgenerate(),
      title = tools::file_path_sans_ext(basename(html_file)),
      htmlFilePath = html_file,
      reloadable = FALSE,
      active = TRUE,
      comments = "",
      jsonData = ""
    )
  })

  jas_data <- list(
    version = JATOS_version,
    data = list(
      uuid = uuid::UUIDgenerate(),
      title = study_title,
      description = study_desc,
      active = TRUE,
      groupStudy = FALSE,
      linearStudy = FALSE,
      dirName = study_title,
      comments = study_comment,
      jsonData = "",
      endRedirectUrl = "",
      componentList = component_list,
      batchList = list(list(
        uuid = uuid::UUIDgenerate(),
        title = "Default",
        active = TRUE,
        maxActiveMembers = NA,
        maxTotalMembers = NA,
        maxTotalWorkers = NA,
        allowedWorkerTypes = list("PersonalSingle", "Jatos", "PersonalMultiple"),
        comments = NA,
        jsonData = ""
      ))
    )
  )

  jas_path <- file.path(root, paste0(study_title, ".jas"))
  on.exit(unlink(jas_path, force = TRUE), add = TRUE)
  jsonlite::write_json(jas_data, jas_path, auto_unbox = TRUE, pretty = TRUE)

  jzip_path <- file.path(output, paste0(study_title, ".jzip"))
  items <- setdiff(list.files(root, full.names = TRUE), jzip_path)
  if (length(items) == 0) {
    stop("There are no files to package in ", root, ".", call. = FALSE)
  }
  zip::zip(zipfile = jzip_path, files = items, root = root, mode = "cherry-pick")
  message("Successfully created: ", jzip_path)
  jzip_path
}
