# Decisions

**Feature ID**: FEATURE-30  
**Last Updated**: 2025-12-27

---

## Decision 1: PR マージ検出方法の選択

**Status**: PENDING  
**Date**: 2025-12-27  
**Decision Maker**: TBD

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

### Decision

**Chosen Option**: TBD

**Rationale**:
<!-- チームでの議論後に記入 -->

**Accepted Risks**:
<!-- 選択したオプションのリスクを記入 -->

**Non-Negotiables**:
- 既存の正常に動作しているケースに影響を与えない
- すべてのマージタイプに対応する
- False positive を最小化する

### Impact

- **Technical**: ワークフローファイルの修正が必要
- **Team**: テストとレビューの工数
- **Timeline**: 選択したオプションに依存
- **Cost**: GitHub API rate limit の考慮（Option B の場合）

### Follow-up Actions

- [ ] チームでオプションを議論
- [ ] 選択したアプローチの詳細設計
- [ ] テストケースの定義

---

## Decision 2: Feature ブランチパターンの厳密性

**Status**: PENDING  
**Date**: 2025-12-27  
**Decision Maker**: TBD

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

#### Option B: 緩いパターン `^feature/`

**Pros**:
- Feature ブランチ命名規則の変更に柔軟に対応
- 実装がシンプル

**Cons**:
- SDLC プロセス外のブランチも処理される可能性
- False positive のリスクが高い

**Cost/Effort**: 低

### Decision

**Chosen Option**: TBD

**Rationale**:
<!-- チームでの議論後に記入 -->

**Accepted Risks**:
<!-- 選択したオプションのリスクを記入 -->

**Non-Negotiables**:
- SDLC プロセスに準拠したブランチのみを処理する

### Impact

- **Technical**: 正規表現パターンの選択
- **Team**: ブランチ命名規則の厳密な遵守が必要（Option A の場合）
- **Timeline**: 最小限
- **Cost**: なし

### Follow-up Actions

- [ ] ブランチ命名規則のドキュメント確認
- [ ] チームの運用方針の確認

---

## Quick Reference

### All Confirmed Decisions

（まだ確定した決定はありません）

### Pending Decisions

1. **PR マージ検出方法の選択**: Option A, B, C から選択 - TBD
2. **Feature ブランチパターンの厳密性**: 厳密 vs 緩い - TBD

---

## Notes

- Issue #30 では Option B（Committer チェック + GitHub API クエリ）が推奨されていますが、チームでの議論と承認が必要です
- 実装前に既存のワークフローの動作を十分にテストすることが重要です
