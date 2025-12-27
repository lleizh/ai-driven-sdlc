# Decisions

**Feature ID**: FEATURE-30  
**Last Updated**: 2025-12-27

---

## Decision 1: PR マージ検出方法の選択

**Status**: CONFIRMED  
**Date**: 2025-12-27  
**Decision Maker**: lleizh

### Context

現在の GitHub Actions ワークフローは commit メッセージの正規表現パターン（`^FEATURE-[0-9]+:`）に依存していますが、conventional commit format（`type(FEATURE-ID):`）には対応していません。より堅牢な検出方法を選択する必要があります。

### Options Considered

#### Option A: Commit メッセージの正規表現パターンを拡張

**Pros**:
- 既存のワークフローロジックを最小限の変更で改善できる
- 追加の API 呼び出しが不要で、実行速度が速い
- GitHub API の rate limit を気にする必要がない

**Cons**:
- Commit メッセージの形式変更に依然として脆弱
- 新しい conventional commit タイプが追加された場合、再度修正が必要
- False positive のリスクが高い（メッセージにパターンが偶然含まれる場合）

**Cost/Effort**: 低（1-2時間）

**Status**: REJECTED

#### Option B: Committer チェック + GitHub API クエリ（推奨）

**Pros**:
- Commit メッセージ形式に完全に依存しない
- GitHub の公式 API を使用して確実に PR 情報を取得
- すべてのマージタイプ（Squash、Merge commit、Rebase）に対応
- False positive のリスクが低い
- 将来の commit メッセージ形式変更に対して堅牢

**Cons**:
- GitHub API の呼び出しが必要（rate limit を考慮）
- 実装が若干複雑になる
- API 呼び出しの失敗をハンドリングする必要がある

**Cost/Effort**: 中（3-4時間）

**Status**: CHOSEN

#### Option C: GitHub webhook を使用した完全な再設計

**Pros**:
- リアルタイムでイベントを検出できる
- より柔軟なロジックを実装可能
- GitHub Actions の実行時間を削減できる

**Cons**:
- 大規模な設計変更が必要
- Webhook エンドポイントのホスティングとメンテナンスが必要
- セキュリティとインフラの考慮が必要
- 過剰な設計（オーバーエンジニアリング）のリスク

**Cost/Effort**: 高（1-2週間）

**Status**: REJECTED

### Decision

**Chosen Option**: Option B - Committer チェック + GitHub API クエリ

**Rationale**:
- Commit メッセージ形式に依存しない堅牢な方法を実現できる
- PR #28 で発生した問題（conventional commit format の検出失敗）を根本的に解決
- GitHub 公式 API を使用することで、将来の commit メッセージ形式変更にも対応可能
- Committer チェックで先にフィルタリングすることで、API 呼び出しを最小限に抑えられる
- すべてのマージタイプ（Squash、Merge commit、Rebase）に対応できる
- Option A は依然として脆弱性が残り、Option C は過剰設計

**Accepted Risks**:
- GitHub API rate limit への到達リスク（低リスク、risks.md R002 で対応済み）
- API 呼び出しの失敗ハンドリングが必要（リトライロジックで対応）
- 実装の複雑度が若干上がる（3-4時間の工数）

**Non-Negotiables**:
- 既存の正常に動作しているケースに影響を与えない
- すべてのマージタイプに対応する
- False positive を最小化する

### Impact

- **Technical**: ワークフローファイル（`.github/workflows/update-feature-status.yml`）の修正が必要
- **Team**: 実装 3-4 時間、テストとレビュー 1-2 時間
- **Timeline**: 1 日以内に完了可能
- **Cost**: GitHub API rate limit の使用量増加（通常は問題なし）

### Follow-up Actions

- [x] チームでオプションを議論 → Option B に決定
- [ ] Committer チェック + GitHub API クエリの詳細実装
- [ ] PR #28 相当のケースでテスト実施
- [ ] 既存の動作ケースでリグレッションテスト

---

## Decision 2: Feature ブランチパターンの厳密性

**Status**: CONFIRMED  
**Date**: 2025-12-27  
**Decision Maker**: lleizh

### Context

PR の head ブランチが feature ブランチかどうかを判定する際、パターンマッチングの厳密性を決定する必要があります。

### Options Considered

#### Option A: 厳密なパターン `^feature/FEATURE-[0-9]+$`

**Pros**:
- False positive が最小限
- SDLC プロセスに完全に準拠したブランチのみを処理
- 予期しない動作を防止

**Cons**:
- 将来的にブランチ命名規則が変更された場合、ワークフローの更新が必要

**Cost/Effort**: 低

**Status**: CHOSEN

#### Option B: 緩いパターン `^feature/`

**Pros**:
- Feature ブランチ命名規則の変更に柔軟に対応
- 実装がシンプル

**Cons**:
- SDLC プロセス外のブランチも処理される可能性
- False positive のリスクが高い

**Cost/Effort**: 低

**Status**: REJECTED

### Decision

**Chosen Option**: Option A - 厳密なパターン `^feature/FEATURE-[0-9]+$`

**Rationale**:
- False positive を最小限に抑え、意図しない Feature の STATUS 更新を防止
- SDLC プロセスに完全に準拠したブランチのみを処理することで、予期しない動作を回避
- Issue #30 の実装例でも厳密なパターンが使用されている
- ブランチ命名規則は既に確立されており、変更の可能性は低い
- risks.md R003 の緩和策（厳密なブランチパターン使用）と一致

**Accepted Risks**:
- 将来的にブランチ命名規則が変更された場合、ワークフローの更新が必要（低リスク、命名規則は安定している）

**Non-Negotiables**:
- SDLC プロセスに準拠したブランチのみを処理する

### Impact

- **Technical**: 正規表現パターン `^feature/FEATURE-[0-9]+$` を使用
- **Team**: ブランチ命名規則の厳密な遵守が必要（既に実施中）
- **Timeline**: 実装時間への影響なし
- **Cost**: なし

### Follow-up Actions

- [x] ブランチ命名規則のドキュメント確認 → `feature/FEATURE-XXX` が標準
- [x] チームの運用方針の確認 → 厳密なパターンで問題なし
- [ ] ワークフローに厳密なパターンを実装

---

## Quick Reference

### All Confirmed Decisions

1. **PR マージ検出方法の選択**: Option B (Committer チェック + GitHub API クエリ) - 2025-12-27
2. **Feature ブランチパターンの厳密性**: Option A (厳密なパターン `^feature/FEATURE-[0-9]+$`) - 2025-12-27

### Pending Decisions

なし

---

## Notes

- Issue #30 では Option B（Committer チェック + GitHub API クエリ）が推奨されていますが、チームでの議論と承認が必要です
- 実装前に既存のワークフローの動作を十分にテストすることが重要です
