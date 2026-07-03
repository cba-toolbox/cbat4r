/*タイムラインの実行*/
jatos.onLoad(() => {
  timeline.unshift(jatos_setting);
  jsPsych.run(timeline);
});