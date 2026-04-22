# AGENTS.md

## Goal
このリポジトリでは、`pbdutil` / `mkfw` の保守・改善を安全に進める。

## Working Rules
- まず現状確認し、変更前に要点を短く共有する。
- 変更は最小差分で行う。
- 指示がない限り、不要なリファクタリングはしない。
- 既存変更（dirty state）がある場合は壊さない。

## Build / Test
- ビルド: `make`
- 個別ビルド: `make pbdutil`, `make mkfw`
- README再生成: `make -B README.md`
- 変更後は最低限、対象に関係するコマンドを実行して結果を報告する。

## Git Rules
- 指定ファイルのみ `git add` する（`git add .` は原則使わない）。
- コミットは1タスク1コミット。
- コミット前に `git status --short` を確認する。
- コミットメッセージは命令形で簡潔にする。
  - 例: `Fix read() error handling in mkfw`

## Editing Rules
- 文字コードは既存に合わせる（通常ASCII/UTF-8）。
- コメントは必要最小限、意図が伝わるものだけ追加。
- manpage (`pbdutil.1`) は mdoc マクロを優先する（`\fB` など直接装飾は避ける）。

## Safety Rules
- 破壊的コマンド（`git reset --hard`, `rm -rf` など）は明示指示がある場合のみ。
- 仕様変更が入る場合は、先に「提案差分」を示して承認後に適用する。
- 不明点が大きいときは、実装より先に確認質問を1つだけ行う。

## Preferred Workflow
1. 調査（関連ファイル・影響範囲）
2. 提案（何をどう直すか）
3. 実装（最小差分）
4. 検証（ビルド/実行）
5. 報告（変更点・検証結果・次の任意アクション）

## Response Style
- 簡潔・具体的に説明する。
- ファイルパスと行番号を添えて説明する。
- 依頼が「変更しないで」の場合は、差分提案のみ提示する。
