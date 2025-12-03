#' @title Create a JATOS .jzip file
#' @importFrom tools file_path_sans_ext
#' @importFrom jsonlite write_json
#' @importFrom uuid UUIDgenerate
#' @importFrom zip zip
#' @param study_title The title of the study. Used for filenames.
#' @param html_file_list A vector of HTML filenames to be used as JATOS components (order is preserved).
#' @param JATOS_version The version of the study (e.g., "3.9.0").
#' @param study_desc A short description of the study (optional).
#' @param study_comment Comments about the study (optional).
#' @param output_dir The output directory for the .jzip file (defaults to the current directory).
#' @examples # jatosify("exp01",c("ic.html","age_gender.html","task01.html"),"3.9")
#' @export
jatosify <- function(study_title,
                     html_file_list,
                     JATOS_version,
                     study_desc = "",
                     study_comment = "",
                     output_dir = ".") {
  # 1. Create the component list from the provided html_file_list ---
  component_list <- lapply(html_file_list, function(html_filename) {
    title <- tools::file_path_sans_ext(html_filename)
    list(
      uuid = uuid::UUIDgenerate(),
      title = title,
      htmlFilePath = html_filename,
      reloadable = FALSE,
      active = TRUE,
      comments = "",
      jsonData = ""
    )
  })
  # 2. Create the default batch list ---
  batch_list <- list(list(
    uuid = uuid::UUIDgenerate(), title = "Default", active = TRUE,
    maxActiveMembers = NA,
    maxTotalMembers = NA,
    maxTotalWorkers = NA,
    allowedWorkerTypes = list("PersonalSingle", "Jatos", "PersonalMultiple"),
    comments = NA,
    jsonData = ""
  ))
  # 3. Assemble the overall JAS data structure ---
  jas_data <- list(
    version = JATOS_version,
    data = list(
      uuid = uuid::UUIDgenerate(), title = study_title, description = study_desc,
      active = TRUE, groupStudy = FALSE, linearStudy = FALSE,
      dirName = study_title, comments = study_comment,
      jsonData = "",
      endRedirectUrl = "", componentList = component_list, batchList = batch_list
    )
  )
  # 4. Create the .jas file in the CWD and ensure it's cleaned up ---
  jas_file_path <- file.path(getwd(), paste0(study_title, ".jas"))
  on.exit(unlink(jas_file_path, force = TRUE), add = TRUE)
  jsonlite::write_json(jas_data, jas_file_path, auto_unbox = TRUE, pretty = TRUE)
  # 5. List all files and directories to be zipped ---
  items_to_zip <- list.files(getwd(), full.names = TRUE)
  if (length(items_to_zip) == 0) {
    stop("The current working directory is empty. No files to zip.")
  }
  # 6. Compress into a JZIP file ---
  output_jzip_path <- file.path(output_dir, paste0(study_title, ".jzip"))
  zip::zip(
    zipfile = output_jzip_path,
    files = items_to_zip,
    root = getwd(),
    mode = "cherry-pick"
  )
  message("Successfully created: ", output_jzip_path)
  return(output_jzip_path)
}
