# Context

**Feature ID**: FEATURE-7  
**Issue Link**: https://github.com/lleizh/ai-driven-sdlc/issues/7  
**Created**: 2025-12-26  
**Last Updated**: 2025-12-26

## Background

現在、SDLC の進捗管理は `./sdlc-cli report` コマンドでしか確認できない。これには以下の課題がある:

- **CLI でしか見れない**: ターミナルでしか確認できず、チーム全体で共有しにくい
- **履歴が残らない**: 過去の状態を追跡できない
- **視覚的に分かりにくい**: テキストベースで全体像が把握しづらい

GitHub Projects v2 と統合することで、チーム全体が GitHub UI で SDLC の状況をリアルタイムに把握できるようになる。

## Problem Statement

チームメンバーが SDLC の進捗状況を可視化・共有する効率的な方法が存在しない。CLI ベースの report コマンドでは、履歴追跡、リアルタイム同期、視覚的な進捗管理ができない。

## Goals

- 各 Issue (Feature) を GitHub Project に自動追加し、カンバンボードで視覚的に進捗管理できる
- commit/push 時に変更された Feature だけを GitHub Actions で自動更新する
- 作業中の未コミット変更は同期せず、確定した変更のみを反映することで git 履歴と Project の状態を一致させる
- Status、Risk Level、Decision Status、Feature ID、Branch、PR Link などのカスタムフィールドで詳細な管理を実現する

## Non-Goals

- 複数の GitHub Project への同時同期
- Project 以外の外部プロジェクト管理ツールとの統合（Jira、Asana など）
- 過去の履歴データの自動移行

## Stakeholders

| Role | Name | Responsibility |
|------|------|----------------|
| Product Owner | TBD | 要件承認・優先度決定 |
| Tech Lead | TBD | 技術的意思決定・レビュー |
| Reviewer | TBD | 設計・実装レビュー |

## Constraints

- GitHub Projects v2 の GraphQL API を使用する必要がある
- API レート制限を考慮した実装が必要
- 既存の SDLC ワークフローを破壊しない形で統合する必要がある
- GitHub Actions の実行時間制限内で処理を完了させる必要がある

## Success Metrics

- `./install.sh` 実行時に GitHub Project が自動的にセットアップされる
- GitHub Actions による自動同期が push 時に正常に動作する（同期成功率 > 95%）
- commit/push された `.metadata` の変更が Project に正しく反映される
- 作業中の未コミット変更は同期されない（git 履歴と Project の状態が一致する）
- GitHub Actions の実行時間が 5 分以内に完了する
- Phase 1-3 の全 Acceptance Criteria が満たされる

## References

- GitHub Projects v2 API: https://docs.github.com/en/graphql/reference/mutations#createprojectv2
- 既存の sdlc-cli report コマンド実装
- .metadata ファイル形式仕様
