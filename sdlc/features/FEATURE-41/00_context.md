# Context（文脈）

**Feature ID**: FEATURE-41  
**Issue Link**: https://github.com/lleizh/ai-driven-sdlc/issues/41  
**Created**: 2025-12-29  
**Last Updated**: 2025-12-29

## Background（背景）

現在の SDLC ドキュメントテンプレートは、生成される文書量が多すぎて読むのに時間がかかる状況です：

- **低リスク Feature**: 3 ファイル、約 495 行
- **中リスク Feature**: 7 ファイル、約 2,386 行
- **高リスク Feature**: 8 ファイル、約 3,000+ 行

これにより以下の問題が発生しています：

1. **読解負担が大きい**: 特に中〜高リスクの Feature では、全文書を読むのに数時間かかる
2. **不要なセクション**: テンプレートに `Assumptions`、`Open Questions` など、`/sdlc-init` の原則に反するセクションが含まれている
3. **冗長な説明文**: AI 生成には不要な長い説明やガイダンスが多い
4. **開発効率の低下**: 文書作成・レビューに時間がかかりすぎる

FEATURE-29 のリファクタリングで SDLC コマンドは改善されましたが、テンプレート自体の最適化が残っています。

## Problem Statement（課題）

SDLC ドキュメントテンプレートが冗長で、文書生成・レビューに過度な時間がかかり、開発効率を低下させている。

## Goals（目標）

- 全 9 つのテンプレートファイルを簡素化する
- `Assumptions`, `Open Questions` など不要なセクションを削除する
- 低リスク Feature の文書量を 300 行以下にする
- 中リスク Feature の文書量を 1,500 行以下にする
- AI が埋めやすい簡潔な構造に変更する

## Non-Goals（非目標）

- 既存 Feature の文書を変更すること（テンプレートは新規作成時のみ使用）
- テンプレートの構造を根本的に変更すること
- SDLC コマンドのロジックを変更すること

## Stakeholders（関係者）

| 役割 | 名前 | 責任 |
|------|------|------|
| Product Owner | TBD | 要件定義、優先順位決定 |
| Tech Lead | TBD | 技術設計、レビュー |
| Reviewer | TBD | 実装レビュー |

## Constraints（制約）

- `/sdlc-init` の原則を厳守する必要がある
- テンプレート構造の大幅な変更は避ける
- 既存の SDLC ワークフローとの互換性を維持する

## Success Metrics（成功指標）

- 低リスク Feature の文書量が 300 行以下になっている
- 中リスク Feature の文書量が 1,500 行以下になっている
- 簡素化したテンプレートで新 Feature を作成し、問題なく動作することを確認
- `/sdlc-init` コマンドのドキュメントが更新されている
- 変更内容が CHANGELOG に記録されている

## References（参考資料）

- FEATURE-29: SDLC コマンドのリファクタリング
- `/sdlc-init` コマンドドキュメント
- 現在のテンプレートファイル: `sdlc/templates/*.md`（9 ファイル、合計 1,614 行）
