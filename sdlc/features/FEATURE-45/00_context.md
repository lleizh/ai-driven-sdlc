# Context（文脈）

**Feature ID**: FEATURE-45  
**Issue Link**: https://github.com/lleizh/ai-driven-sdlc/issues/45  
**Created**: 2026-01-09  
**Last Updated**: 2026-01-09

## Background（背景）

`install.sh` スクリプトに2つの重大な問題が報告されており、特定の環境でインストールが失敗する状況が発生しています:

1. **パイプ実行での失敗**: 推奨されているインストール方法である `curl | bash` でユーザー入力を受け付けられず、自動的にキャンセルされる
2. **Organization リポジトリでの失敗**: GitHub Project 作成時に無効な owner ID が使用され、Organization リポジトリで GitHub Projects の自動セットアップが完全に失敗する

これらの問題は、インストールスクリプトが標準的な使用シナリオ（パイプ実行、Organization リポジトリ）で動作しないという重大な UX 問題を引き起こしています。

## Problem Statement（課題）

現在の `install.sh` スクリプトには以下の3つの技術的問題があります:

1. **stdin 占有による read 失敗** (Lines 146-151)
   - パイプ実行時、stdin がパイプに占有されているため `read` コマンドがユーザー入力を受け付けられない
   - `$REPLY` が空文字列となり、確認チェックが失敗して自動キャンセルされる

2. **GraphQL クエリの型エラー** (Lines 366-373)
   - `user` クエリのみを使用しているため、Organization では失敗する
   - エラー JSON が `$OWNER_ID` に格納され、空チェックをパスしてしまう
   - 無効な ID で GraphQL mutation が実行され、API エラーで終了する

3. **macOS sed の非互換性** (Around line 297)
   - GNU sed と BSD sed の正規表現構文の違いにより、macOS でリポジトリ URL のパースが失敗する

## Goals（目標）

- `curl | bash` でのインストールを正常に動作させる（非対話モードの検出と自動続行）
- 個人リポジトリと Organization リポジトリの両方で GitHub Project を作成できるようにする
- macOS (BSD sed) でリポジトリ URL のパースが正常に動作するようにする
- GitHub API エラーを適切に検出・処理し、無効な ID で API 呼び出しが行われないようにする

---

## Non-Goals（非目標）

- Windows 環境でのインストールサポート（現時点では bash 前提）
- インストール済み環境の移行やアップグレード機能
- GitHub Project 以外のプロジェクト管理ツールのサポート

## References（参考資料）

- 元の Issue: https://github.com/lleizh/ai-driven-sdlc/issues/44
- GitHub GraphQL API - RepositoryOwner: https://docs.github.com/en/graphql/reference/unions#repositoryowner
- Bash read command: https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html#index-read
