# Decisions

**Feature ID**: FEATURE-7  
**Last Updated**: 2025-12-26

---

## Decision 1: Project セットアップの方式

**Status**: CONFIRMED  
**Date**: 2025-12-26  
**Decision Maker**: Team Discussion

### Context

GitHub Project を使用するために、Project の作成とカスタムフィールドの設定が必要。セットアップのタイミングと方法を決定する必要がある。

### Options Considered

#### Option A: install.sh で自動セットアップ
**Pros**:
- ユーザーの手間が最小限（インストール時に自動完了）
- 標準的な設定が自動で適用される
- セットアップ忘れがない
- 既存の install.sh フローに統合できる

**Cons**:
- 組織によっては Project 作成権限がない場合がある
- カスタマイズの柔軟性が低い
- インストール時間が少し長くなる

**Cost/Effort**: 中（install.sh の拡張と API 実装）

#### Option B: 専用コマンドで手動セットアップ
**Pros**:
- ユーザーが任意のタイミングで実行できる
- エラー時の対処がしやすい
- インストールと分離できる

**Cons**:
- セットアップ忘れのリスク
- 別コマンドの実行が必要で手間
- ドキュメントが複雑化

**Cost/Effort**: 中（専用コマンドの実装）

#### Option C: 既存 Project の URL 指定をサポート
**Pros**:
- 組織の標準 Project に統合しやすい
- 権限問題を回避できる

**Cons**:
- 実装が複雑
- カスタムフィールドの整合性確認が必要
- MVP としては過剰

**Cost/Effort**: 高（URL パースと検証ロジック）

### Decision
**Chosen Option**: Option A - install.sh で自動セットアップ

**Rationale**:
- インストール時に全てセットアップが完了し、ユーザーの手間が最小限
- セットアップ忘れを防げる
- 標準的な構成で始められ、学習コストが低い
- 既存の install.sh フローに自然に統合できる

**Accepted Risks**:
- 組織によっては Project 作成権限がない場合がある（エラーメッセージで対処）

**Non-Negotiables**:
- カスタムフィールドの整合性は必ず確保する
- エラー時には分かりやすいメッセージを表示する
- 認証失敗時はスキップして後で再実行可能にする

### Impact
- **Technical**: install.sh に Project セットアップロジックを追加
- **Team**: インストール時に GitHub 認証が必要なことを理解する必要がある
- **Timeline**: 1-2週間（install.sh の拡張と API 実装）
- **Cost**: インストール時の API コール（初回のみ）

### Follow-up Actions
- [x] install.sh で自動セットアップする方針を確定
- [ ] GitHub Projects v2 API の権限要件を確認
- [ ] エラーハンドリングとリトライ機能の実装

---

## Decision 2: 自動同期のトリガータイミング

**Status**: CONFIRMED  
**Date**: 2025-12-26  
**Decision Maker**: Team Discussion

### Context

`.metadata` の変更を GitHub Project に反映するタイミングを決定する必要がある。リアルタイム性とパフォーマンス、API レート制限のバランスを考慮する必要がある。

### Options Considered

#### Option A: 全 push で全 Feature をスキャン
**Pros**:
- 実装がシンプル
- 確実に最新状態を反映できる
- git diff の複雑なロジックが不要

**Cons**:
- API コール数が多い
- レート制限に引っかかりやすい
- 大規模リポジトリでは遅い

**Cost/Effort**: 低（実装は簡単だが運用コストが高い）

#### Option B: 変更された Feature のみ更新（push 時）
**Pros**:
- API コール数を最小化
- パフォーマンスが良い
- スケーラブル
- git 履歴と Project の状態が一致する
- commit/push された確定変更のみ同期

**Cons**:
- git diff の解析が必要
- rename/move の検出が複雑
- 稀に同期漏れの可能性

**Cost/Effort**: 中（git diff ロジックの実装）

#### Option C: SDLC コマンド実行時に即座に同期
**Pros**:
- リアルタイムで Project が更新される
- 実装がシンプル

**Cons**:
- 作業中の未確定変更も同期される
- git 履歴と Project の状態が乖離する
- API コール数が多い
- ロールバックが困難

**Cost/Effort**: 低（実装は簡単だが設計として不適切）

### Decision
**Chosen Option**: Option B - 変更された Feature のみ更新（push 時）

**Rationale**:
- commit/push された変更のみを同期することで、git 履歴と Project の状態を一致させる
- 作業中の試行錯誤は同期せず、確定した変更のみを反映する
- API コール数を最小化し、スケーラビリティを確保
- 変更の追跡とロールバックが可能

**Accepted Risks**:
- git diff の実装が複雑になる可能性（ただし標準的な手法で対応可能）

**Non-Negotiables**:
- commit/push された変更のみを同期する
- 作業中の未コミット変更は同期しない
- API レート制限を超えない
- 同期エラー時には適切なログを出力する

### Impact
- **Technical**: GitHub Actions ワークフローで git diff 処理が必要
- **Team**: commit/push 後に Project が更新されることを理解する必要がある
- **Timeline**: 2週間（git diff ロジックの実装とテスト）
- **Cost**: GitHub Actions 実行時間は変更された Feature のみのため最小限

### Follow-up Actions
- [x] GitHub API のレート制限を調査（5,000 req/hour で十分）
- [x] commit/push ベースの同期タイミングを確認

---

## Decision 3: カスタムフィールドのデータ形式

**Status**: PENDING  
**Date**: 2025-12-26  
**Decision Maker**: TBD

### Context

GitHub Projects v2 のカスタムフィールドにどのような形式でデータを保存するか決定する必要がある。`.metadata` の形式と Project のフィールドのマッピングを定義する必要がある。

### Options Considered

#### Option A: Issue の How 案をそのまま使用
**Pros**:
- 要件に明確に定義されている
- 必要な情報が揃っている
- Status、Risk Level、Decision Status などが網羅されている

**Cons**:
- フィールド数が多い（7つ）
- Project UI が複雑になる可能性
- 将来の拡張性が制限される

**Cost/Effort**: 中（各フィールドの設定と同期ロジック）

#### Option B: 最小限のフィールドのみ
**Pros**:
- UI がシンプル
- セットアップが簡単
- メンテナンスが容易

**Cons**:
- 情報が不足する
- 詳細を確認するには CLI が必要
- 可視化のメリットが減る

**Cost/Effort**: 低（実装は簡単だが価値が低い）

#### Option C: 段階的追加（Phase 1 は最小限、Phase 2 で拡張）
**Pros**:
- 段階的に価値を提供
- 初期リリースが早い
- フィードバックを反映できる

**Cons**:
- マイグレーションが必要
- 既存データの更新が必要
- Phase 2 の計画が必要

**Cost/Effort**: 中（段階的な実装と移行）

### Decision
**Chosen Option**: TBD

**Rationale**:
<!-- チームで議論して決定 -->

**Accepted Risks**:
- TBD

**Non-Negotiables**:
- 少なくとも Status と Feature ID は必須
- `.metadata` との整合性を保つ

### Impact
- **Technical**: カスタムフィールド管理の複雑性
- **Team**: Project UI の使いやすさ
- **Timeline**: Option A/B は 1週間、Option C は Phase 分散
- **Cost**: API コール数とデータ量

### Follow-up Actions
- [ ] チームメンバーに必要なフィールドをヒアリング
- [ ] 既存の Project 使用例を調査

---

## Decision History

### Revisions

<!-- 決定が変更された場合にここに記録 -->

---

## Quick Reference

### All Confirmed Decisions
1. **Project セットアップの方式**: Option A（install.sh で自動セットアップ） - 2025-12-26
2. **自動同期のトリガータイミング**: Option B（push 時に変更された Feature のみ更新） - 2025-12-26

### Pending Decisions
1. **カスタムフィールドのデータ形式**: Option A/B/C を検討中

---

## Notes

- Issue の Phase 1-4 の Acceptance Criteria は明確に定義されているため、これらを実装の指針とする
- GitHub Projects v2 API は GraphQL ベースのため、REST API とは異なる実装が必要
- 既存の sdlc-cli コマンドとの統合を優先し、破壊的変更は避ける
