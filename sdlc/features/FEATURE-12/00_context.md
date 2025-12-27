# Context

**Feature ID**: FEATURE-12  
**Issue Link**: https://github.com/lleizh/ai-driven-sdlc/issues/12  
**Created**: 2025-12-26  
**Last Updated**: 2025-12-26

## Background
`/sdlc-check` コマンドが実装されているが、Implementation Plan に記載されたタスク（特に Documentation、Testing など）の完成度をチェックしていない。これにより、実装は完了していてもドキュメントが未完成のまま PR がマージされる可能性がある。

FEATURE-7 の実装時に、`30_implementation_plan.md` に以下のタスクが記載されていたにもかかわらず、`/sdlc-check` で検出されなかった：
- README に Project 統合機能を追加
- install.sh の使用方法を更新
- トラブルシューティングガイドの作成

## Problem Statement
機能は動作するがドキュメントが不足した状態で PR がマージされてしまう問題がある。`/sdlc-check` コマンドが Implementation Plan のタスク完成度を検証していないため、Documentation や Testing などの重要なタスクが未完了のまま見過ごされる。

## Goals
`/sdlc-check` コマンドを拡張し、`30_implementation_plan.md` に記載された全タスクの完成度を検証する。
- Implementation Plan のタスク解析機能を追加（`- [ ]` と `- [x]` をパース）
- 未完了タスクをカテゴリ別にリスト化（Backend, Frontend, Documentation, Testing など）
- 完成度の評価機能を追加（Documentation、Testing、Core 実装の完成度を判定）
- レポート機能の改善（未完了タスクを明示的に表示、カテゴリごとの完成率を表示）

## Non-Goals
- 他の SDLC コマンドの拡張（本機能は `/sdlc-check` のみを対象）
- タスクの自動完了や自動修正機能
- Implementation Plan 以外のファイルのタスク解析

## Stakeholders
| Role | Name | Responsibility |
|------|------|----------------|
| Product Owner | TBD | 機能要件の承認 |
| Tech Lead | TBD | 技術的判断、実装レビュー |
| Reviewer | TBD | コードレビュー |

## Constraints
- 既存の `/sdlc-check` コマンドの動作に影響を与えない
- bash スクリプトでの実装（`.claude/commands/sdlc-check.md` の拡張）
- 既存の SDLC ワークフローとの互換性を維持

## Success Metrics
- `/sdlc-check` が `30_implementation_plan.md` の全タスクをパースできる
- 未完了の Documentation タスクを警告として表示する
- 未完了の Testing タスクを警告として表示する（High Risk の場合はブロッカー）
- 未完了の Core 実装タスクをブロッカーとして表示する
- カテゴリごとの完成率が表示される
- FEATURE-7 で `/sdlc-check` を実行すると、README 未更新が警告として検出される

## References
- 関連 Issue: FEATURE-7 の `/sdlc-check` 実行結果
- 既存コマンド: `.claude/commands/sdlc-check.md`
