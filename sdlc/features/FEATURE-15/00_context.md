# Context

**Feature ID**: FEATURE-15  
**Issue Link**: https://github.com/lleizh/ai-driven-sdlc/issues/15  
**Created**: 2025-12-26  
**Last Updated**: 2025-12-26

## Background

現在のプロジェクトの分岐戦略は以下の通り：
- `develop`: 主開発ブランチ
- `feature/FEATURE-XXX`: 低リスク機能の開発
- `design/FEATURE-XXX`: 中/高リスク機能の Design Review
- `master`: 本番リリース用

しかし、現状では以下の問題がある：
1. **`develop` ブランチが存在しない** - `/sdlc-init` は develop から分岐する設計だが、実際には存在しない
2. **Workflow が `master`/`main` のみをトリガー** - feature/design ブランチでの `.metadata` 変更が GitHub Projects に同期されない
3. **開発中の進捗が見えない** - merge するまで Project に反映されない

これにより、開発者は実装中の Feature の進捗を GitHub Projects で追跡できず、プロジェクト管理が困難になっている。

## Problem Statement

現在の GitHub Actions Workflow は `master` ブランチでの `.metadata` 変更のみをトリガーするため、feature/design ブランチでの開発進捗が merge されるまで GitHub Projects に反映されない。これにより：
- 開発中の Feature の STATUS 変更が見えない
- DECISION_STATUS の更新が追跡できない
- チーム全体でのプロジェクト進捗の可視性が低い

## Goals

1. `develop` ブランチを作成し、今後の feature/design ブランチは develop から分岐する
2. GitHub Actions Workflow を拡張し、すべての開発ブランチ（master, develop, feature/**, design/**）での `.metadata` 変更を GitHub Projects に同期する
3. 各ブランチでの commit/push 時に即座に Project を更新し、merge を待たずに進捗を可視化する

## Non-Goals

- GitHub Projects の構造変更（カラム、フィールドなど）
- `.metadata` フォーマットの変更
- Workflow の実行頻度や性能の最適化（基本的な同期機能の実現に集中）

## Stakeholders

| Role | Name | Responsibility |
|------|------|----------------|
| Product Owner | TBD | 要件承認、優先度決定 |
| Tech Lead | TBD | 技術的判断、実装レビュー |
| Reviewer | TBD | コードレビュー、動作確認 |

## Constraints

- GitHub Actions の実行制限内で動作すること（無料枠や実行時間制限）
- 既存の master ブランチでの動作を変更しない（後方互換性）
- PAT（Personal Access Token）の権限は最小限にする

## Success Metrics

- `develop` ブランチが作成され、origin に push されている
- `.github/workflows/sync-projects.yml` が master, develop, feature/**, design/** でトリガーされる
- feature ブランチで `.metadata` を変更して push すると、GitHub Projects が更新される
- design ブランチで `.metadata` を変更して push すると、GitHub Projects が更新される
- develop ブランチで `.metadata` を変更して push すると、GitHub Projects が更新される
- master ブランチでの動作は既存通り（変更なし）
- 既存の PR（#14など）の base が develop に変更されている
- README に develop ブランチの説明が追加されている

## References

- 関連 PR: #14 (FEATURE-12 の実装 PR、現在 base が master)
- 既存 Workflow: `.github/workflows/sync-projects.yml`
- 設計文書: `.claude/commands/sdlc-init.md` (develop 前提の設計)
