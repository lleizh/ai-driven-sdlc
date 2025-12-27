# Context（文脈）

**Feature ID**: FEATURE-19  
**Issue Link**: https://github.com/lleizh/ai-driven-sdlc/issues/19  
**Created**: 2025-12-27  
**Last Updated**: 2025-12-27

## Background（背景）

現在の SDLC ワークフローでは、Feature の完了ステータスを手動で更新する必要があります。具体的には：

- PR がマージされた後、`.metadata` の STATUS を手動で `completed` に変更する必要がある
- 手動更新は忘れやすく、Feature のステータスが不正確になる可能性がある
- ワークフローの完全な自動化が実現できていない

この結果、以下の問題が発生しています：
- Feature のステータス管理が不完全
- 進行中の Feature と完了した Feature の区別が不明確
- 監査証跡が不正確になる可能性

FEATURE-10 の実装完了後、「いつ STATUS を completed に更新するか」を議論した結果、以下の判断に至りました：
- `/sdlc-check` での更新は不適切（check は状態を変更しない）
- `/sdlc-close` コマンドの新設よりも、自動化が望ましい

## Problem Statement（課題）

PR が develop にマージされた後も Feature の STATUS が `implementing` のままになり、手動で `completed` に更新する必要がある。これはヒューマンエラーの原因となり、Feature のステータス管理の正確性を損なう。

## Goals（目標）

- PR が develop にマージされたときに、自動的に Feature の STATUS を `completed` に更新する
- 手動更新の手間を削減する
- ステータスの正確性を保証する
- GitHub Projects の Status も自動同期（既存の `sync-projects.yml` が自動的にトリガーされ "Completed" に更新）

## Non-Goals（非目標）

- design/* ブランチのマージ時の STATUS 更新（Design Review PR は対象外）
- develop 以外のブランチへのマージ時の STATUS 更新
- `.metadata` 以外のファイルの自動更新

## Stakeholders（関係者）

| 役割 | 名前 | 責任 |
|------|------|------|
| Product Owner | TBD | 要件定義、受け入れ基準承認 |
| Tech Lead | TBD | 技術的判断、実装承認 |
| Reviewer | TBD | コードレビュー、動作確認 |

## Constraints（制約）

- FEATURE-20 が先に完了している必要がある（"Status" 字段の統一）
- GitHub Actions の GITHUB_TOKEN を使用（develop ブランチへの push 権限が必要）
- feature/* ブランチのマージのみが対象
- Branch protection rules との整合性を保つ必要がある

## Success Metrics（成功指標）

- PR マージ後の `.metadata` STATUS 自動更新率 100%
- 手動での STATUS 更新作業の削減（0 件を目標）
- GitHub Actions Workflow の実行成功率 > 95%
- `.metadata` ファイルが存在しない場合のエラーハンドリング率 100%

## References（参考資料）

- FEATURE-10: `/sdlc-test` コマンド実装
- FEATURE-20: GitHub Projects Status 字段統一
- GitHub Actions `pull_request.closed` event documentation
- Branch protection rules best practices
