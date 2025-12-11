# cbat4r

cbat4r is an R package designed to facilitate the creation and management of cognitive behavioral tasks and questionnaires for online experiments, specifically integrating with JATOS and jsPsych.

## Installation

You can install the package from GitHub:

```r
# install.packages("devtools")
devtools::install_github("cba-toolbox/cbat4r")
```

## Functions

### 1. jatosify

Creates a JATOS `.jzip` file from a list of HTML files. This file can be imported directly into JATOS.

**Usage:**

```r
jatosify(study_title, html_file_list, JATOS_version, study_desc = "", study_comment = "", output_dir = ".")
```

**Arguments:**

*   `study_title`: The title of the study. Used for filenames.
*   `html_file_list`: A vector of HTML filenames to be used as JATOS components (order is preserved).
*   `JATOS_version`: The version of the study (e.g., "3.9.0").
*   `study_desc`: A short description of the study (optional).
*   `study_comment`: Comments about the study (optional).
*   `output_dir`: The output directory for the .jzip file (defaults to the current directory).

**Example:**

```r
jatosify("exp01", c("ic.html", "age_gender.html", "task01.html"), "3.9")
```

### 2. set_cbat

Initializes a new directory for a task and sets up the necessary files to run a jsPsych experiment (CBAT). It supports multiple versions of jsPsych.

**Usage:**

```r
set_cbat(task_name = "task_name", jsPsych_version = "8.2.2")
```

**Arguments:**

*   `task_name`: The name of the task. A directory with this name will be created.
*   `jsPsych_version`: The version of jsPsych to use (e.g., "6.3.1", "7.3.4", "8.2.2").

**Example:**

```r
# Initialize a task named "stroop" with jsPsych version 8.2.2
set_cbat(task_name = "stroop", jsPsych_version = "8.2.2")
```

### 3. set_qnr

Creates a directory and prepares necessary files (HTML, JS, CSS) to run a questionnaire task using jsPsych (Likert scale).

**Usage:**

```r
set_qnr(task_name = "task_name", scale, item, instruction, randomize_order = "false", jsPsych_version = "8.2.2")
```

**Arguments:**

*   `task_name`: A character string specifying the name of the task.
*   `scale`: A character vector defining the default scale labels.
*   `item`: A data frame defining the questionnaire items (columns: 'prompt', 'required', 'name', 'labels').
*   `instruction`: A character string specifying the instruction text.
*   `randomize_order`: "true" or "false" indicating whether to randomize question order.
*   `jsPsych_version`: The version of jsPsych to use.

**Example:**

```r
scale_list <- c("Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree")
items <- data.frame(
  prompt = c("I feel happy.", "I feel energetic."),
  required = c("true", "true"),
  name = c("happy", "energetic"),
  labels = c("scale", "scale")
)
set_qnr(task_name = "mood_survey",
        scale = scale_list,
        item = items,
        instruction = "Please answer the following questions.",
        randomize_order = true,
        jsPsych_version = "8.2.2")
```

### 4. set_phaser

Sets up template files for a Phaser3 game.

**Usage:**

```r
set_phaser(game_name = "game_name", phaser_version = "3.80.1", use_rc = TRUE)
```

**Arguments:**

*   `game_name`: Name of the game/task.
*   `phaser_version`: Version of Phaser to use.
*   `use_rc`: If TRUE, checks for an "exercise" directory. If FALSE, creates in current directory.

**Example:**

```r
set_phaser("game1", "3.80.1", FALSE)
```
