# Context

**Feature ID**: FEATURE-30  
**Issue Link**: https://github.com/lleizh/ai-driven-sdlc/issues/30  
**Created**: 2025-12-27  
**Last Updated**: 2025-12-27

## Background

現在の GitHub Actions ワークフロー（`.github/workflows/update-feature-status.yml`）は、PR のマージを検出する際に commit メッセージの正規表現パターンマッチング（`^FEATURE-[0-9]+:`）に依存しています。しかし、この方法では conventional commit format（例：`feat(FEATURE-27):`）を使用した commit メッセージを正しく検出できず、PR #28 のマージ時にワークフローが発火しませんでした。

正規表現パターンだけに依存する方法は脆弱で、commit メッセージの形式変更に弱いという問題があります。

## Problem Statement

PR のマージが発生しても、conventional commit format を使用している場合、GitHub Actions ワークフローがマージを検出できず、Feature の STATUS が自動的に `completed` に更新されない問題が発生しています。

具体的には、PR #28 の squash merge（commit メッセージ: `feat(FEATURE-27): implement archive command for completed features (#28)`）が検出されず、FEATURE-27 の STATUS が手動更新が必要となりました。

## Goals

- Squash merge、Merge commit、Rebase merge すべてのマージタイプを確実に検出する
- Conventional commit format（`type(FEATURE-ID):`）を含む様々な commit メッセージ形式に対応する
- Feature の STATUS を自動的に `completed` に更新する
- Commit メッセージ形式に依存しない堅牢な検出方法を実装する

## Non-Goals

- GitHub Actions ワークフロー以外の自動化機能の追加
- SDLC ドキュメント生成ロジックの変更
- 他のワークフローへの影響

## Stakeholders

| Role | Name | Responsibility |
|------|------|----------------|
| Product Owner | TBD | Requirements approval |
| Tech Lead | TBD | Technical review |
| Reviewer | TBD | Code review |

## Constraints

- GitHub Actions の実行環境とツールに制約される
- GitHub API の rate limit を考慮する必要がある
- 既存の正常に動作しているケースに影響を与えない

## Success Metrics

- Conventional commit format（`type(FEATURE-ID):`）を使用したマージが 100% 検出される
- すべてのマージタイプ（Squash merge、Merge commit、Rebase merge）で正常に動作する
- Feature ブランチ以外のマージでは発火しない（false positive = 0）
- PR #28 相当のケースでテスト済み

## References

- 問題が発生した PR: #28 (FEATURE-27)
- 現在のワークフロー: `.github/workflows/update-feature-status.yml`
- 関連 Issue: #29 (SDLC コマンドのリファクタリング)
