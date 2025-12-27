# Context（文脈）

**Feature ID**: FEATURE-27  
**Issue Link**: https://github.com/lleizh/ai-driven-sdlc/issues/27  
**Created**: 2025-12-27  
**Last Updated**: 2025-12-27

## Background（背景）

プロジェクトが成熟するにつれて、`sdlc/features/` ディレクトリに完了した Feature の文書が蓄積していく。現在、完了した Feature を削除または整理するメカニズムが存在しないため、以下の問題が発生する：

- ディレクトリが肥大化し、アクティブな Feature を見つけにくくなる
- Git 操作（clone、pull、diff など）が遅くなる可能性がある
- 新規メンバーが現在進行中の作業と完了済みの作業を区別しにくくなる
- ディスク容量を無駄に消費する

## Problem Statement（課題）

完了した Feature（`STATUS=completed`）を適切に整理・アーカイブする仕組みが必要。手動での移動は忘れられがちで、一貫性が保たれない。

## Goals（目標）

- 完了した Feature を自動的に `sdlc/archive/` ディレクトリに移動する
- アーカイブの条件（経過日数）を設定可能にする
- Dry-run モードで事前に確認できる
- 年ごとに整理されたアーカイブ構造を維持する
- Git 履歴を保持したまま移動する（`git mv` 使用）

## Non-Goals（非目標）

- Feature の完全な削除機能（アーカイブのみ、削除はしない）
- 外部ストレージ（S3など）への移動
- アーカイブされた Feature の自動削除
- GitHub Projects からの Issue 削除（Projects 上は Done として残す）

## Stakeholders（関係者）

| 役割 | 名前 | 責任 |
|------|------|------|
| Product Owner | TBD | 要件定義、受け入れ |
| Tech Lead | TBD | 設計レビュー、承認 |
| Developer | AI | 実装 |

## Constraints（制約）

- `sdlc-cli` は Bash スクリプトで実装されている
- `.metadata` ファイルのフォーマットを維持する必要がある
- Git 履歴を保持する必要がある（`git mv` を使用）
- 既存の `sdlc-cli` コマンドとの一貫性を保つ

## Success Metrics（成功指標）

- `./sdlc-cli archive` コマンドで完了済み Feature を正しく検出できる
- 指定した日数を超えた Feature のみが移動される
- `--dry-run` で実際の移動前に確認できる
- アーカイブ後も `.metadata` が正しく機能する
- `sdlc/archive/YYYY/` ディレクトリ構造が正しく作成される

## References（参考資料）

- [STATUS_MANAGEMENT.md](../../../STATUS_MANAGEMENT.md) - STATUS フィールドの定義
- [sdlc-cli](../../../sdlc-cli) - 既存の管理ツール
