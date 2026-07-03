# jsPsych version handling and template configuration.

LEGACY_JSPSYCH_VERSION <- "6.3.1"

# Versions verified against upstream jsPsych releases. Newer 7.x/8.x releases
# are also accepted: the release archive URL is derived from the version
# string, so new upstream versions work without updating cbat4r.
KNOWN_JSPSYCH_VERSIONS <- c(
  "6.3.1",
  "7.1.1", "7.1.2", "7.2.1", "7.2.2",
  "7.3.0", "7.3.1", "7.3.2", "7.3.3", "7.3.4",
  "8.0.0", "8.0.1", "8.0.2", "8.0.3",
  "8.1.0",
  "8.2.0", "8.2.1", "8.2.2"
)

# Return the validated major version of a jsPsych version string.
version_family <- function(jsPsych_version) {
  if (!is.character(jsPsych_version) || length(jsPsych_version) != 1 ||
      is.na(jsPsych_version) || !grepl("^[0-9]+\\.[0-9]+\\.[0-9]+$", jsPsych_version)) {
    stop("jsPsych version must look like '8.2.2', got ",
         deparse(jsPsych_version), ".", call. = FALSE)
  }
  as.integer(strsplit(jsPsych_version, ".", fixed = TRUE)[[1]][1])
}

# Validate a jsPsych version for set_cbat() and return its major version.
validate_cbat_version <- function(jsPsych_version) {
  major <- version_family(jsPsych_version)
  if (major == 6) {
    if (jsPsych_version != LEGACY_JSPSYCH_VERSION) {
      stop("jsPsych ", jsPsych_version, " is not available. ",
           "The only supported jsPsych 6 version is ", LEGACY_JSPSYCH_VERSION, ".",
           call. = FALSE)
    }
    return(major)
  }
  if (major < 6 || startsWith(jsPsych_version, "7.0.")) {
    stop("jsPsych ", jsPsych_version, " is not available.", call. = FALSE)
  }
  major
}

# Validate a jsPsych version for set_qnr()/set_ic() (jsPsych 7+ only).
validate_qnr_ic_version <- function(jsPsych_version) {
  major <- validate_cbat_version(jsPsych_version)
  if (major < 7) {
    stop("jsPsych ", jsPsych_version,
         " is not available for this task type; use jsPsych 7 or later.",
         call. = FALSE)
  }
  major
}

jspsych_folder <- function(jsPsych_version) {
  if (jsPsych_version == LEGACY_JSPSYCH_VERSION) {
    paste0("jspsych-", LEGACY_JSPSYCH_VERSION)
  } else {
    "jspsych"
  }
}

template_family <- function(jsPsych_version) {
  if (jsPsych_version == LEGACY_JSPSYCH_VERSION) "cbat6" else "cbat7plus"
}
