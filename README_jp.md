# cbat4r

[English README here](README.md)

cbat4rは、オンライン実験のための認知行動課題や質問紙の作成・管理を支援するRパッケージです。特にJATOSおよびjsPsychとの連携を想定して設計されています。

同一のAPIを持つPython版が [pycbat](https://github.com/cba-toolbox/pycbat) として提供されています。

[template-jsPsych-task](https://github.com/ykunisato/template-jsPsych-task) のテンプレート資産（HTMLエントリーポイント、init/runスクリプト、雛形の `task.js`、刺激画像、カスタムプラグイン）はパッケージに同梱されているため、課題の作成にテンプレートのダウンロードは不要です。ダウンロードされるのは公式のjsPsych配布物のみで、バージョンごとに一度だけダウンロードしてキャッシュします（キャッシュ先は `tools::R_user_dir("cbat4r", "cache")`、または環境変数 `CBAT4R_CACHE_DIR` が設定されていればそちら）。そのため、2回目以降の課題作成はオフラインで動作します。

## インストール

GitHubからインストールできます。

```r
# install.packages("remotes")
remotes::install_github("cba-toolbox/cbat4r")
```

## 関数

すべての `set_*` 関数は次の引数を共通で持ちます。

*   `output_dir`: 課題ディレクトリを作成する場所（既定はカレントワーキングディレクトリ）。
*   `overwrite`: `overwrite = TRUE` を指定しない限り、既存の課題ディレクトリは上書きされません。

### 1. set_cbat

課題用の新しいディレクトリを作成し、jsPsych実験（CBAT）を実行するために必要なファイルを準備します。Demo・JATOS・CEMAの各環境向けのHTMLエントリーポイント、init/runスクリプト、雛形の `task.js`、既定の刺激画像、そして公式のjsPsych配布物が含まれます。

**使い方:**

```r
set_cbat(task_name = "task_name", jsPsych_version = "8.2.2",
         output_dir = ".", overwrite = FALSE)
```

**引数:**

*   `task_name`: 課題名。この名前のディレクトリが作成されます。
*   `jsPsych_version`: 使用するjsPsychのバージョン（例: "6.3.1", "7.3.4", "8.2.2"）。このパッケージより新しいものを含め、jsPsych 7.1以降のリリースであれば動作します。

**例:**

```r
# jsPsych 8.2.2 で "stroop" という課題を初期化する
set_cbat(task_name = "stroop", jsPsych_version = "8.2.2")
```

これにより以下が作成されます。

```text
stroop/
  README_stroop.md
  demo_stroop.html          # ローカルで実行
  stroop.html               # JATOS上で実行
  cema_stroop.html          # CEMA上で実行（jsPsych 7以降のみ）
  stroop/
    jspsych/                # 公式のjsPsych配布物 + カスタムプラグイン
    stimuli/
    *_jspsych_init.js / *_jspsych_run.js
    task.js                 # ここに課題を記述する
```

### 2. set_qnr

`task.js` にリッカート尺度の質問紙を提示するCBAT課題を作成します。jsPsych 7以降が必要です。

**使い方:**

```r
set_qnr(task_name = "scale_name", scale, item, instruction = "",
        randomize_order = FALSE, jsPsych_version = "8.2.2",
        output_dir = ".", overwrite = FALSE)
```

**引数:**

*   `task_name`: 課題名を指定する文字列。
*   `scale`: 尺度のラベルを定義する文字列ベクトル。
*   `item`: `prompt` と `name` 列を持つデータフレーム。任意で `required`（既定は `TRUE`）と `labels`（尺度ラベルを保持するJS変数名、既定は `"scale"`）を指定できます。
*   `instruction`: 教示文を指定する文字列。
*   `randomize_order`: 質問の順序をランダム化するかどうか（`TRUE`/`FALSE`。`"true"`/`"false"` も可）。
*   `jsPsych_version`: 使用するjsPsychのバージョン。

**例:**

```r
scale_list <- c("まったく当てはまらない", "当てはまらない", "どちらともいえない", "当てはまる", "非常に当てはまる")
items <- data.frame(
  prompt = c("私は幸せだと感じる。", "私は元気だと感じる。"),
  name = c("happy", "energetic")
)
set_qnr(task_name = "mood_survey",
        scale = scale_list,
        item = items,
        instruction = "以下の質問にお答えください。",
        randomize_order = TRUE)
```

### 3. set_ic

インフォームド・コンセントの文書（Markdownから変換）を表示し、参加者に同意チェックボックスへのチェックを求めるCBAT課題を作成します。jsPsych 7以降が必要です。

**使い方:**

```r
set_ic(task_name = "ic", ic_markdown, ic_question = "...", ic_agree_label = "...",
       jsPsych_version = "8.2.2", output_dir = ".", overwrite = FALSE)
```

**引数:**

*   `task_name`: 課題名を指定する文字列。既定は "ic"。
*   `ic_markdown`: IC文をMarkdown形式で記述した文字列、または .md ファイルへのパス。
*   `ic_question`: 同意確認の質問文。既定は英語（"Do you agree..."）。
*   `ic_agree_label`: 同意チェックボックスのラベル。既定は英語（"I have read..."）。
*   `jsPsych_version`: 使用するjsPsychのバージョン。

**例:**

```r
ic_text <- "
# インフォームド・コンセント
本研究では...について検討します。
## 目的
本研究の目的は...
"

set_ic(task_name = "consent_task", ic_markdown = ic_text)

# または Markdown ファイルから:
# set_ic(task_name = "consent_task", ic_markdown = "path/to/consent.md")
```

### 4. set_cc

クラウドソーシングサイトなどで調査を行った際に、研究の最後にランダム生成した参加ID（完了コード）を提示するCBAT課題を作成します。参加者にはコードをコピーしてから終了するよう求め、コードは試行データにも保存されます。[completion-code](https://github.com/cba-toolbox/completion-code) のCBAT形式版です。jsPsych 7以降が必要です。

**使い方:**

```r
set_cc(task_name = "completion_code", jsPsych_version = "8.2.2",
       output_dir = ".", overwrite = FALSE)
```

引数の指定は不要です。

```r
set_cc()
```

### 5. jatosify

HTMLファイルのリストからJATOSの `.jzip` ファイルを作成します。このファイルはJATOSに直接インポートできます。

**使い方:**

```r
jatosify(study_title, html_file_list, JATOS_version,
         study_desc = "", study_comment = "", output_dir = ".", root_dir = ".")
```

**引数:**

*   `study_title`: 研究のタイトル。ファイル名に使われます。
*   `html_file_list`: JATOSのコンポーネントとして使うHTMLファイル名のベクトル（順序は保持されます）。
*   `JATOS_version`: 研究のバージョン（例: "3.9.0"）。
*   `study_desc`: 研究の簡単な説明（任意）。
*   `study_comment`: 研究に関するコメント（任意）。
*   `output_dir`: `.jzip` ファイルの出力先ディレクトリ（既定はカレントディレクトリ）。
*   `root_dir`: パッケージ化する対象ディレクトリ（既定はカレントディレクトリ）。

**例:**

```r
jatosify("exp01", c("ic.html", "age_gender.html", "task01.html"), "3.9.0")
```

### 6. set_phaser

Phaser3ゲーム用のテンプレートファイルを準備します。

**使い方:**

```r
set_phaser(game_name = "game_name", phaser_version = "3.80.1", use_rc = TRUE,
           output_dir = ".", overwrite = FALSE)
```

**引数:**

*   `game_name`: ゲーム/課題の名前。
*   `phaser_version`: 使用するPhaserのバージョン。
*   `use_rc`: `TRUE` の場合、既存の "exercise" ディレクトリ内にゲームを作成します。`FALSE` の場合は `output_dir` に作成します。

**例:**

```r
set_phaser("game1", "3.80.1", use_rc = FALSE)
```

## 開発

テストスイートの実行（オフラインで動作します。jsPsychのアーカイブは `CBAT4R_CACHE_DIR` を通じて疑似的に用意されます）:

```r
testthat::test_local()
```
