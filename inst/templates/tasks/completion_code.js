/* 完了コードの設定 */
const id_no = jsPsych.randomization.randomID(10);

const finish = {
  type: jsPsychHtmlButtonResponse,
  stimulus: '<p style="font-size:30px;">これで研究参加は終了になります。</p>' +
  　'<p style="font-size:30px;">研究にご参加いただき，誠にありがとうございました。</p>' +
    '<p style="font-size:30px;">あなたの参加IDは，<span style="color:#6495ED;"> ' + id_no + ' </span>です</p>' +
    '<p style="font-size:20px;">同意撤回時に必要になりますので、紙にメモし，参加IDをコピーしてから，以下の「終了」をクリックして終了ください</p>',
  choices: ['終了'],
  data: {id: id_no}
};

/*タイムラインの設定*/
const timeline = [finish];
