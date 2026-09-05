# `pbdutil` と他の macOS クリップボードツールの比較

`pbdutil` は、単に `pbcopy` / `pbpaste` を高機能にした代替コマンドでは
ありません。最大の持ち味は、macOS Pasteboard の小さな CLI フロントエンド
として、アプリケーションが登録した表現型を調査し、選択した表現型の生データ
を読み書きできることです。

この性質から、コピー＆ペースト互換性の診断、テキスト以外のデータ抽出、AppKit
Pasteboard の実験に特に向いています。新しいツールには、より広い形式への対応や
洗練されたワークフローがありますが、`NSPasteboard` をこれほど小さく直接的に
扱えることは、今も `pbdutil` の特徴です。

## 概要

| ツール | 対応環境 | 主な用途 | 型付きデータ | 調査機能 | 書き込み | 主な制約 |
|---|---|---|---|---|---|---|
| `pbcopy` / `pbpaste` | macOS | 日常的なテキストのパイプ処理 | テキストと限定的な RTF/EPS | なし | あり | 任意の表現型を1つだけ指定して取得できない |
| **`pbdutil`** | macOS | AppKit Pasteboard の調査と操作 | テキスト、画像、リッチテキスト、PDF、URL などの固定エイリアス | 型とサイズの詳細一覧、番号による生データ取得 | 1回につき1表現型 | 任意 UTI の指定と複数表現型の同時書き込みができない |
| `pbrich` | macOS | リッチまたは型指定した内容の書き込み | 任意の UTI、一般的な形式は自動判定 | 一般的な型の一覧のみで、現在の内容は調査しない | 複数型とファイル参照 | 主に書き込み向け |
| `copycat` | macOS、Linux、Windows | クロスプラットフォームの生データ調査と入出力 | OS 固有の任意の形式識別子 | 一覧、プレビュー、JSON、監視 | CLI は1形式、C API は複数形式のアトミック書き込み | `pbdutil` より対象範囲と抽象化が大きい |
| `pngpaste` | macOS | クリップボード画像の保存と変換 | 一般的な画像入力・出力形式 | なし | なし | 画像専用でファイル出力が前提 |
| `pbimg` | macOS | クリップボード画像のファイルまたは stdout 出力 | 画像データ | なし | なし | 画像抽出専用 |
| `clippy` | macOS | Terminal から GUI アプリへファイルやリッチコンテンツをコピー | ファイル参照と自動判定・リッチ形式 | 関連ツールによるワークフロー寄りの調査 | あり | 低レベルな生形式デバッガではない |

## `pbcopy` / `pbpaste` との比較

標準コマンドは、意図的に範囲を絞った Unix 風のインターフェースです。
`pbcopy` は stdin を読み込み、通常はプレーンテキストとして格納しますが、RTF と
EPS のヘッダーは特別に認識します。`pbpaste` は優先されるテキスト系の表現型を
stdout に出力します。`-Prefer` で text、RTF、PostScript の検索順を変えられます
が、任意の Pasteboard type だけに取得対象を限定することはできません。

通常のシェル利用では、この単純さが利点です。

```sh
printf '%s' 'hello' | pbcopy
pbpaste > note.txt
```

形式そのものが重要な場合に `pbdutil` が役立ちます。

```sh
pbdutil -r png > image.png
pbdutil -r html > fragment.html
pbdutil -w pdf < document.pdf
```

現在のソースは `text`, `txt`, `tiff`, `png`, `pdf`, `html`, `rtf`, `rtfd`,
`tab`, `url`, `path`, `font` というエイリアスを AppKit の
`NSPasteboardType` 定数へ対応付けています。また、`pbcopy`、`pbpaste`、
`pbclear` という名前でインストールすると、それぞれの互換モードで動作します。

## `pbdutil` を特徴付ける調査機能

macOS の Pasteboard は、同じ論理的な内容に対して複数の表現型を公開できます。
たとえばブラウザは、1回のコピー操作でプレーンテキスト、HTML、RTF、さらに
アプリケーション固有の表現型を登録し、貼り付け先のアプリケーションが理解できる
最適な形式を選べるようにします。

`pbdutil` はそれらの表現型を可視化します。

```sh
pbdutil -l
pbdutil -lv
pbdutil -lvv
pbdutil -lvvv
```

最初の3段階では、対応するエイリアス、ネイティブの型名、サイズを表示します。
`-lvvv` では、エイリアステーブルにないものを含む全型を番号付きで表示します。
その番号から生データを取得できます。

```sh
pbdutil -R 3 > representation.bin
```

ある GUI アプリケーションから貼り付けた内容が別のアプリケーションで異なる動作を
する理由を調べる際に有用です。標準コマンドには同等の一覧機能がありません。

`pbdutil` は named/private Pasteboard も扱えます。

```sh
pbdutil -n scratch -w text
pbdutil -n scratch -r text
pbdutil -n scratch -d
```

クリップボード CLI としては珍しい機能で、AppKit の実験や簡単なローカル IPC に
利用できます。`-c` は Pasteboard を消去し、`-C` は公開されている型の数を表示
します。

## 最大の制約: 書き込める表現型は1つだけ

`pbdutil` は書き込み前に、要素が1つだけの型配列を宣言します。

```objc
[pbd declareTypes:[NSArray arrayWithObject:type] owner:nil];
[pbd setData:data forType:type];
```

そのため `-w` を実行するたび、Pasteboard の内容は単一の表現型で置き換えられ
ます。一般的なアプリケーションのコピー操作のように、
`public.utf8-plain-text`、`public.html`、`public.rtf` を同時に公開することは
できません。また、指定できるのは組み込みエイリアスだけです。`-R` は未知の型を
番号で読み出せますが、`-w` で任意の UTI 文字列を書き込むことはできません。

補助プログラム `mkfw` は、限定的ながらこの周辺を補完します。
`pbdutil -r rtfd` で読み出したシリアライズ済み RTFD データを、RTFD file
wrapper として展開できます。

## リッチ形式と任意形式: `pbrich` と `copycat`

macOS のクリップボードへリッチコンテンツを書き込むことが目的なら、`pbrich` が
有力です。一般的なバイナリ形式の自動判定、`-t` による任意 UTI、プレーンテキスト
のフォールバック、ファイル参照、1回の操作での複数型登録に対応しています。

```sh
echo '<b>hello</b>' | pbrich -t public.html -p 'hello'
pbrich -f report.pdf
echo '<b>bold</b>' | pbrich -t public.html -t public.rtf
```

中心となるのは書き込み機能です。すでに Pasteboard に存在する表現型を調べる用途
では、`pbdutil` の方が手軽です。

`copycat` は、現代的な汎用ツールとして最も近い比較対象です。クリップボードを、
OS 固有の形式識別子から生データへのマップとして扱います。macOS では UTI、Linux
では主に MIME type、Windows では Clipboard Format 名を使います。CLI から一覧、
調査、読み書き、消去、監視、JSON 出力ができます。

```sh
copycat list
copycat read public.html > page.html
cat page.html | copycat write public.html
copycat --json
copycat watch
```

リモートシェル向けの OSC 52 にも対応し、複数形式をアトミックに書き込める C API
も公開しています。`pbdutil` より移植性とスクリプト連携に優れ、形式名も自由です。
一方 `pbdutil` は小さな macOS ネイティブツールで、named Pasteboard を扱え、短い
エイリアスで操作できます。

## 画像専用ツール: `pngpaste` と `pbimg`

単にクリップボード画像を保存するなら、`pngpaste` の方が目的に合っています。

```sh
pngpaste screenshot.png
```

クリップボード入力として PNG、PDF、GIF、TIFF、JPEG を受け付け、ファイルの拡張子
に応じて PNG、GIF、JPEG、TIFF を出力します。生の Pasteboard データを公開する
のではなく、画像として解釈・変換するツールです。

`pbimg` も同様に目的が明確で、画像を指定ファイルまたは stdout に出力できます。

```sh
pbimg screenshot.png
pbimg > screenshot.png
```

画像を手軽に取得するなら、これらのツールが適しています。Pasteboard に PNG、
TIFF、PDF のどれがあるか、画像の表現型が複数あるかを調べたい場合や、厳密に1つの
表現型のバイト列が必要な場合は `pbdutil` が適しています。

## ファイル中心のワークフロー: `clippy`

ファイルを `pbcopy` に通すと、Mail や Slack が期待する Finder 形式のファイル
参照ではなく、ファイルのバイト列がコピーされます。`clippy` はこの差を埋めるため
のツールです。

```sh
clippy report.pdf
clippy *.jpg
```

さらに、内容の型判定、HTML/RTF/plain text のリッチ形式、最近のダウンロードの
選択、MCP server など、Terminal 向けの機能を備えています。これらは高水準の
作業効率化機能です。Pasteboard API を使う点では `pbdutil` と重なりますが、目的は
異なります。`clippy` はコピー操作を便利にし、`pbdutil` は Pasteboard に実際に
何が入っているかを公開します。

## どれを選ぶか

- macOS で通常のテキストをパイプ処理するなら、標準搭載で利用しやすい
  `pbcopy` / `pbpaste`。
- Pasteboard の型一覧、特定表現型の生データ、named Pasteboard、アプリケーション
  間の互換性を調べるなら `pbdutil`。
- macOS で任意 UTI、複数表現型、ファイル参照を書き込むなら `pbrich`。
- macOS、Linux、Windows で任意形式を調査・入出力し、JSON、監視、リモートシェル
  対応も必要なら `copycat`。
- 画像を保存することが目的なら `pngpaste` または `pbimg`。
- Finder に近いファイルコピーや、より豊かな Terminal-to-GUI ワークフローが
  必要なら `clippy`。

端的に言えば、`pbcopy` / `pbpaste` はテキストのパイプ処理ツールで、`pbdutil` は
小さな `NSPasteboard` 調査・操作ツールです。実装は昔ながらで意図的に小規模ですが、
その直接性には今も価値があります。

## 参照資料

- [`pbdutil` リポジトリ](https://github.com/rok-git/pbdutil)およびこのリポジトリの
  ソースコード
- macOS に付属する `pbcopy(1)` / `pbpaste(1)` man page
- [Apple `NSPasteboard` documentation](https://developer.apple.com/documentation/appkit/nspasteboard)
- [`pbrich`](https://github.com/waynehoover/pbrich)
- [`copycat`](https://github.com/georgemandis/copycat)
- [`pngpaste`](https://github.com/jcsalterego/pngpaste)
- [`pbimg`](https://github.com/paulsmith/pbimg)
- [`clippy`](https://github.com/neilberkman/clippy)

情報は2026年9月5日に確認しました。サードパーティ製ツールの機能は、以後変更される
可能性があります。
