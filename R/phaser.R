# Phaser starter generation.

phaser_html <- function(phaser_version) {
  paste(c(
    "<!DOCTYPE html>",
    "<html>",
    " <head>",
    paste0('  <script src="//cdn.jsdelivr.net/npm/phaser@', phaser_version,
           '/dist/phaser.js"></script>'),
    " </head>",
    " <body></body>",
    ' <script type="text/javascript" src="task.js"></script>',
    "</html>",
    ""
  ), collapse = "\n")
}

phaser_task_js <- function() {
  paste(c(
    "class Example extends Phaser.Scene {",
    "  preload () {",
    "    this.load.setBaseURL('https://labs.phaser.io');",
    "    this.load.image('sky', 'assets/skies/space3.png');",
    "    this.load.image('logo', 'assets/sprites/phaser3-logo.png');",
    "    this.load.image('red', 'assets/particles/red.png');",
    "  }",
    "  create () {",
    "    this.add.image(400, 300, 'sky');",
    "    const particles = this.add.particles(0, 0, 'red', {",
    "      speed: 100,",
    "      scale: { start: 1, end: 0 },",
    "      blendMode: 'ADD'",
    "    });",
    "    const logo = this.physics.add.image(400, 100, 'logo');",
    "    logo.setVelocity(100, 200);",
    "    logo.setBounce(1, 1);",
    "    logo.setCollideWorldBounds(true);",
    "    particles.startFollow(logo);",
    "  }",
    "}",
    "",
    "const config = {",
    "  type: Phaser.AUTO,",
    "  width: 800,",
    "  height: 600,",
    "  scene: Example,",
    "  physics: {",
    "    default: 'arcade',",
    "    arcade: { gravity: { y: 200 } }",
    "  }",
    "};",
    "",
    "const game = new Phaser.Game(config);",
    ""
  ), collapse = "\n")
}

#' Create a Phaser 3 starter project
#'
#' Creates a directory with an HTML entry point (loading Phaser from a CDN),
#' a starter `task.js`, and an empty `assets/` directory.
#'
#' @param game_name Name of the game, used as the directory name. Must be a
#'   path-safe name.
#' @param phaser_version Phaser version loaded from the jsDelivr CDN.
#' @param use_rc If `TRUE`, the game is created inside the `exercise/`
#'   directory used by the RC teaching environment (which must already
#'   exist); if `FALSE`, it is created directly under `output_dir`.
#' @param output_dir Base directory. Defaults to the current working
#'   directory.
#' @param overwrite If `TRUE`, an existing game directory is replaced.
#' @return (Invisibly) the path of the created game directory.
#' @examples
#' \dontrun{
#' set_phaser("game1", "3.80.1", use_rc = FALSE)
#' }
#' @export
set_phaser <- function(game_name = "game_name",
                       phaser_version = "3.80.1",
                       use_rc = TRUE,
                       output_dir = ".",
                       overwrite = FALSE) {
  validate_name(game_name, "game_name")
  base <- normalizePath(output_dir, mustWork = TRUE)
  if (isTRUE(use_rc)) {
    base <- file.path(base, "exercise")
    if (!dir.exists(base)) {
      stop("Run in a directory containing the 'exercise' directory, ",
           "or use use_rc = FALSE.", call. = FALSE)
    }
  }
  root <- file.path(base, game_name)
  ensure_clean_target(root, overwrite)
  dir.create(root, showWarnings = FALSE, recursive = TRUE)
  write_text(file.path(root, paste0(game_name, ".html")),
             phaser_html(phaser_version))
  write_text(file.path(root, "task.js"), phaser_task_js())
  dir.create(file.path(root, "assets"), showWarnings = FALSE)
  invisible(root)
}
