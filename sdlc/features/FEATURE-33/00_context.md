# Context（文脈）

**Feature ID**: FEATURE-33  
**Issue Link**: https://github.com/lleizh/ai-driven-sdlc/issues/33  
**Created**: 2025-12-27  
**Last Updated**: 2025-12-27

## Background（背景）

現在の `.github/workflows/update-feature-status.yml` は、PR が develop にマージされた際に Feature の STATUS を `completed` に更新しますが、対応する GitHub Issue は自動的にクローズされません。

これにより以下の問題が発生します：
- Issue の状態と Feature の STATUS が不一致になる
- 手動で Issue をクローズする必要がある
- SDLC ワークフローの自動化が不完全

## Problem Statement（課題）

PR が develop にマージされ、Feature が完了した際に、対応する GitHub Issue が自動的にクローズされない問題があります。これにより、Issue の状態管理が手動となり、Feature の STATUS と Issue の状態が不一致になる可能性があります。

## Goals（目標）

- PR が develop にマージされ、Feature の STATUS が `completed` に更新される際に、対応する GitHub Issue を自動的にクローズする
- `.metadata` から ISSUE_URL を抽出し、Issue 番号を解析する
- GitHub CLI または API を使用して Issue をクローズする
- クローズ時に自動化によるものであることをコメントで明記する
- SDLC ワークフローの自動化を完全にする

## Non-Goals（非目標）

- 既存の STATUS 更新機能の変更
- 他のワークフローへの影響
- Issue の再オープン機能
- 手動での Issue クローズの禁止

## Stakeholders（関係者）

| 役割 | 名前 | 責任 |
|------|------|------|
| Product Owner | TBD | 機能要件の承認 |
| Tech Lead | TBD | 技術的実装の承認 |
| Reviewer | TBD | コードレビュー |

## Constraints（制約）

- GitHub Actions の実行環境で動作すること
- `GITHUB_TOKEN` の権限で Issue をクローズできること
- 既存の `update-feature-status.yml` との互換性を保つこと
- `.metadata` ファイルの形式に依存すること

## Success Metrics（成功指標）

- PR が develop にマージされた際、対応する Issue が自動的にクローズされる（成功率 100%）
- Issue クローズ時に自動化によるものであることが明記される
- ISSUE_URL が存在しない、または無効な場合のエラーハンドリングが実装されている
- 既存の STATUS 更新機能に影響を与えない
- workflow のログに Issue クローズの成功/失敗が記録される

## References（参考資料）

- 既存 Workflow: `.github/workflows/update-feature-status.yml`
- 関連 Feature: FEATURE-19 (PR マージ時の STATUS 自動更新)
- 調査結果: 現在の workflow は Issue をクローズしていない
