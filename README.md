# cbat4r

[日本語版 README はこちら](README_jp.md)

cbat4r is an R package designed to facilitate the creation and management of cognitive behavioral tasks and questionnaires for online experiments, specifically integrating with JATOS and jsPsych.

A Python port with the same API is available as [pycbat](https://github.com/cba-toolbox/pycbat).

The template assets of [template-jsPsych-task](https://github.com/ykunisato/template-jsPsych-task) (HTML entry points, init/run scripts, starter `task.js`, stimuli, custom plugins) are bundled with the package, so task creation needs no template download. Only the official jsPsych distribution is downloaded — once per version — and cached (in `tools::R_user_dir("cbat4r", "cache")`, or `$CBAT4R_CACHE_DIR` if set), so repeated task creation works offline.

## Installation

You can install the package from GitHub:

```r
# install.packages("remotes")
remotes::install_github("cba-toolbox/cbat4r")
```

## Functions

All `set_*` functions share these arguments:

*   `output_dir`: Directory in which the task directory is created (defaults to the current working directory).
*   `add_root_dir`: If `TRUE` (the default), a root directory named `task_name` is created inside `output_dir` and the HTML entry points and the `task_name` task directory are placed in it. If `FALSE`, they are placed directly in `output_dir`. Either way, if a directory named `task_name` already exists at the target location, an error is raised and nothing is created (unless `overwrite = TRUE`).
*   `overwrite`: Existing task directories are never overwritten unless `overwrite = TRUE`.

### 1. set_cbat

Initializes a new directory for a task and sets up the necessary files to run a jsPsych experiment (CBAT): HTML entry points for the Demo, JATOS, and CEMA environments, init/run scripts, a starter `task.js`, default stimuli, and the official jsPsych distribution.

**Usage:**

```r
set_cbat(task_name = "task_name", jsPsych_version = "8.2.2",
         output_dir = ".", add_root_dir = TRUE, overwrite = FALSE)
```

**Arguments:**

*   `task_name`: The name of the task. A directory with this name will be created.
*   `jsPsych_version`: The version of jsPsych to use (e.g., "6.3.1", "7.3.4", "8.2.2"). Any jsPsych 7.1+ release works, including releases newer than this package.

**Example:**

```r
# Initialize a task named "stroop" with jsPsych version 8.2.2
set_cbat(task_name = "stroop", jsPsych_version = "8.2.2")
```

This creates:

```text
stroop/
  README_stroop.md
  demo_stroop.html          # run locally
  stroop.html               # run on JATOS
  cema_stroop.html          # run on CEMA (jsPsych 7+ only)
  stroop/
    jspsych/                # official jsPsych distribution + custom plugins
    jspsych-mobile.css      # mobile-friendly styling for survey/likert plugins
    stimuli/
    *_jspsych_init.js / *_jspsych_run.js
    task.js                 # write your task here
```

Each HTML entry point loads `jspsych-mobile.css` after `jspsych.css`. It makes the `survey-likert` / `survey` plugins mobile-friendly: on screens 700px wide or narrower, Likert options stack vertically (they stay in a row on wider screens).

With `add_root_dir = FALSE`, the same HTML files and the `stroop/` task directory are placed directly in `output_dir` instead of inside a wrapping `stroop/` root directory:

```r
set_cbat(task_name = "stroop", output_dir = "my_study", add_root_dir = FALSE)
```

```text
my_study/
  README_stroop.md
  demo_stroop.html
  stroop.html
  cema_stroop.html
  stroop/
    jspsych/ ...
```

### 2. set_qnr

Creates a CBAT task whose `task.js` presents a Likert-scale questionnaire. Requires jsPsych 7+.

**Usage:**

```r
set_qnr(task_name = "scale_name", scale, item, instruction = "",
        randomize_order = FALSE, jsPsych_version = "8.2.2",
        output_dir = ".", add_root_dir = TRUE, overwrite = FALSE)
```

**Arguments:**

*   `task_name`: A character string specifying the name of the task.
*   `scale`: A character vector defining the scale labels.
*   `item`: A data frame with columns `prompt` and `name`; optionally `required` (default `TRUE`) and `labels` (name of the JS variable holding the scale labels, default `"scale"`).
*   `instruction`: A character string specifying the instruction text.
*   `randomize_order`: Whether to randomize question order (`TRUE`/`FALSE`; `"true"`/`"false"` also accepted).
*   `jsPsych_version`: The version of jsPsych to use.

**Example:**

```r
scale_list <- c("Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree")
items <- data.frame(
  prompt = c("I feel happy.", "I feel energetic."),
  name = c("happy", "energetic")
)
set_qnr(task_name = "mood_survey",
        scale = scale_list,
        item = items,
        instruction = "Please answer the following questions.",
        randomize_order = TRUE)
```

### 3. set_ic

Creates a CBAT task that shows an informed-consent document (converted from Markdown) and requires the participant to check an agreement box. Requires jsPsych 7+.

**Usage:**

```r
set_ic(task_name = "ic", ic_markdown, ic_question = "...", ic_agree_label = "...",
       jsPsych_version = "8.2.2", output_dir = ".", add_root_dir = TRUE,
       overwrite = FALSE)
```

**Arguments:**

*   `task_name`: A character string specifying the name of the task. Default is "ic".
*   `ic_markdown`: A character string containing the IC text in Markdown format, or a path to a .md file.
*   `ic_question`: A character string for the consent question. Default is English ("Do you agree...").
*   `ic_agree_label`: A character string for the consent checkbox label. Default is English ("I have read...").
*   `jsPsych_version`: The version of jsPsych to use.

**Example:**

```r
ic_text <- "
# Informed Consent
This study investigates...
## Purpose
The purpose is...
"

set_ic(task_name = "consent_task", ic_markdown = ic_text)

# Or from a markdown file:
# set_ic(task_name = "consent_task", ic_markdown = "path/to/consent.md")
```

### 4. set_cc

Creates a CBAT task that shows a randomly generated participation ID (completion code) at the end of a study, as used on crowdsourcing platforms. The participant is asked to copy the code before finishing; the code is also stored in the trial data. This is the CBAT-format equivalent of [completion-code](https://github.com/cba-toolbox/completion-code). Requires jsPsych 7+.

**Usage:**

```r
set_cc(task_name = "completion_code", jsPsych_version = "8.2.2",
       output_dir = ".", add_root_dir = TRUE, overwrite = FALSE)
```

No arguments are required:

```r
set_cc()
```

### 5. jatosify

Creates a JATOS `.jzip` file from a list of HTML files. This file can be imported directly into JATOS.

**Usage:**

```r
jatosify(study_title, html_file_list, JATOS_version,
         study_desc = "", study_comment = "", output_dir = ".", root_dir = ".")
```

**Arguments:**

*   `study_title`: The title of the study. Used for filenames.
*   `html_file_list`: A vector of HTML filenames to be used as JATOS components (order is preserved).
*   `JATOS_version`: The version of the study (e.g., "3.9.0").
*   `study_desc`: A short description of the study (optional).
*   `study_comment`: Comments about the study (optional).
*   `output_dir`: The output directory for the .jzip file (defaults to the current directory).
*   `root_dir`: The directory whose contents are packaged (defaults to the current directory).

**Example:**

```r
jatosify("exp01", c("ic.html", "age_gender.html", "task01.html"), "3.9.0")
```

### 6. set_phaser

Sets up template files for a Phaser3 game.

**Usage:**

```r
set_phaser(game_name = "game_name", phaser_version = "3.80.1", use_rc = TRUE,
           output_dir = ".", overwrite = FALSE)
```

**Arguments:**

*   `game_name`: Name of the game/task.
*   `phaser_version`: Version of Phaser to use.
*   `use_rc`: If TRUE, creates the game inside the existing "exercise" directory. If FALSE, creates in `output_dir`.

**Example:**

```r
set_phaser("game1", "3.80.1", use_rc = FALSE)
```

## Development

Run the test suite (offline; jsPsych archives are faked through `CBAT4R_CACHE_DIR`):

```r
testthat::test_local()
```
