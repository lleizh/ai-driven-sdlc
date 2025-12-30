# Context（文脈）

**Feature ID**: FEATURE-42  
**Issue Link**: https://github.com/lleizh/ai-driven-sdlc/issues/42  
**Created**: 2025-12-30  
**Last Updated**: 2025-12-30

## Background（背景）

現在の AI-Driven SDLC において、PR Review の内容を構造化して記録する仕組みがありません：

1. **Review Findings の記録不足**: PR Review は GitHub 上で行われるが、正式な記録として残らない
2. **監査追跡の困難**: 過去の Review 内容を振り返るのが難しい
3. **AI Review との統合**: CodeRabbit など AI Review Bot の結果を活用できていない
4. **手動作業の負担**: Review 内容を整理する必要がある場合、手作業になる

AI_SDLC.md には「必要なら 40_review_findings.md に要約」と記載されているが、現在これを自動生成するツールがありません。

## Problem Statement（課題）

PR Review の内容が体系的に記録されず、以下の問題が発生しています：

- レビューコメントが GitHub 上に散在し、重要な指摘が埋もれる
- 過去のレビュー内容を検索・参照するのが困難
- AI Review Bot の指摘を活用する仕組みがない
- レビュー結果をプロジェクト文書として残すには手動でまとめる必要がある

## Goals（目標）

- `/sdlc-review-summary` コマンドで PR Review 内容を自動抽出・分類できる
- 構造化された `40_review_findings.md` を自動生成できる
- Critical / Important / Suggestions に自動分類できる
- AI Review Bot のコメントも統合できる（オプション）
- 極限まで簡素化されたインターフェース（feature-id のみ指定）

---

### For Medium Risk（中リスクの場合は以下も記入）

## Success Metrics（成功指標）

- `/sdlc-review-summary <feature-id>` コマンドが正常に動作する
- PR から Review Comments を自動抽出し、適切に分類できる
- `40_review_findings.md` が正しいフォーマットで生成される
- Low/Medium/High Risk Feature それぞれでテストが通る
- AI Review Bot がいる PR でも正常に動作する（Phase 2）

---

### Optional（全リスクレベル共通：必要に応じて記入）

## Non-Goals（非目標）

- GitHub 以外のプラットフォーム（GitLab, Bitbucket 等）への対応
- リアルタイムでのレビュー追跡
- レビューコメントの自動応答
- 過去の全 PR を一括処理する機能

## References（参考資料）

- AI_SDLC.md: 「必要なら 40_review_findings.md に要約」の記載
- SDLC_FLOW.md: Design Review → Code Review の明確な順序
- `/sdlc-pr-design`: Design Review PR 作成コマンド
- `/sdlc-pr-code`: Code Review PR 作成コマンド
- `/sdlc-check`: Self-Check（ファイルに記録しない）との差別化
