# Context

**Feature ID**: FEATURE-3  
**Issue Link**: https://github.com/lleizh/ai-driven-sdlc/issues/3  
**Created**: 2025-12-26  
**Last Updated**: 2025-12-26

## Background
現在の AI-Driven SDLC フレームワークでは、特定の GitHub Label（`feature`, `bug`, `risk:high`, `design-review`, `implementation`, `decision-revision`）が必要です。しかし、これらの Label はユーザーが手動で作成する必要があり、以下の問題が発生しています：

1. **エラーの発生**: `/sdlc-pr-code` などのコマンド実行時に "label not found" エラーが発生
2. **セットアップの摩擦**: ユーザーが Label の存在を事前に知らず、エラーに遭遇して初めて気づく
3. **ドキュメント負荷**: README に Label 作成手順を記載する必要がある

## Problem Statement
SDLC コマンド（`/sdlc-pr-code` など）を実行する際、必要な GitHub Label が存在しないとエラーが発生し、ユーザーは手動で Label を作成する必要がある。これによりユーザー体験が悪化し、フレームワークの導入障壁が高くなっている。

## Goals
- `install.sh` に Label 初期化機能を追加し、必要な Label を自動作成する
- ユーザーが手動で Label を作成する手間を削減する
- SDLC コマンド実行時の "label not found" エラーを防止する
- フレームワークのセットアップをスムーズにする

## Non-Goals
- 既存の Label を変更・削除する機能は含まない
- Label の色やデフォルト設定をカスタマイズする機能は含まない（将来の scope）
- GitHub Enterprise や self-hosted GitHub への対応は含まない（将来の scope）

## Stakeholders
| Role | Name | Responsibility |
|------|------|----------------|
| Product Owner | TBD | 要件確認・承認 |
| Tech Lead | TBD | 設計レビュー・実装承認 |
| Reviewer | TBD | コードレビュー |

## Constraints
- `gh` コマンドが利用可能な環境でのみ動作する
- GitHub 認証（`gh auth login`）が完了していることが前提
- Git リポジトリ内でのみ実行される
- リモートリポジトリ（origin）が設定されていることが前提

## Success Metrics
- `install.sh` 実行後、6つの必須 Label が自動的に作成される
- `gh` コマンドが存在しない場合や認証エラーの場合、適切な警告メッセージが表示される
- 既存 Label は重複作成されない（冪等性が保証される）
- SDLC コマンド実行時の "label not found" エラーが発生しなくなる

## References
- Issue: https://github.com/lleizh/ai-driven-sdlc/issues/3
- GitHub CLI Label コマンド: https://cli.github.com/manual/gh_label
