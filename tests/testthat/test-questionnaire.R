test_that("likert_task_js embeds items with JSON escaping", {
  items <- data.frame(
    prompt = c("I feel happy.", "I'm \"fine\"."),
    name = c("happy", "fine")
  )
  js <- likert_task_js(
    scale = c("低い", "高い"),
    item = items,
    instruction = "次の質問に答えてください",
    randomize_order = "true"
  )
  expect_match(js, "type: jsPsychSurveyLikert", fixed = TRUE)
  expect_match(js, 'prompt: "I feel happy.", required: true, name: "happy", labels: scale',
               fixed = TRUE)
  expect_match(js, 'prompt: "I\'m \\"fine\\"."', fixed = TRUE)
  expect_match(js, "randomize_question_order: true", fixed = TRUE)
  expect_match(js, 'preamble: "次の質問に答えてください"', fixed = TRUE)
  expect_match(js, '"低い"', fixed = TRUE)
})

test_that("likert_task_js honors optional required/labels columns", {
  items <- data.frame(
    prompt = "q1", name = "q1", required = "false", labels = "my_scale"
  )
  js <- likert_task_js(c("a", "b"), items, "", FALSE)
  expect_match(js, "required: false", fixed = TRUE)
  expect_match(js, "labels: my_scale", fixed = TRUE)
})

test_that("likert_task_js validates the item data frame", {
  expect_error(likert_task_js(c("a"), data.frame(prompt = "x"), ""),
               "'prompt' and 'name'")
})
