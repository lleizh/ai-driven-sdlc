# Decisions（決定事項）

**Feature ID**: FEATURE-41  
**Last Updated**: 2025-12-29

---

## Decision 1: テンプレート簡素化の実装順序

**Status**: PENDING  
**Date**（日付）: 2025-12-29  
**Decision Maker**（意思決定者）: TBD

### Context（背景）

9 つのテンプレートファイルを簡素化する際、どの順序で実装するかを決定する必要がある。Issue では Phase 2 で優先順位順に実装することが提案されている。

### Options Considered（検討した選択肢）

#### Option A: Issue 提案の優先順位順（必須 → 中〜高リスク → 高リスク専用）

**Pros**（長所）:
- 全リスクレベルで共通の必須テンプレートから開始
- 段階的に複雑度の高いテンプレートに移行
- Issue で提案された順序で実装が明確

**Cons**（短所）:
- 低リスク Feature の検証が早い段階でできる
- 中〜高リスクテンプレートの検証に時間がかかる

**Cost/Effort**（コスト・工数）: 6 日（Phase 2: 3 日、Phase 3: 1 日、Phase 4: 1 日）

#### Option B: 使用頻度順（低リスク → 中リスク → 高リスク）

**Pros**（長所）:
- 使用頻度の高い低リスクテンプレートから検証可能
- 早期にフィードバックを得られる
- 影響範囲の小さいものから開始

**Cons**（短所）:
- テンプレート間の依存関係を考慮していない
- 実装順序が複雑になる可能性

**Cost/Effort**（コスト・工数）: 6 日

#### Option C: リスクレベル別並行作業

**Pros**（長所）:
- 最も高速に完了できる
- 各リスクレベルのテンプレートを独立して作業可能

**Cons**（短所）:
- 一貫性の確保が困難
- 共通パターンの抽出が難しい
- レビュー負担が増加

**Cost/Effort**（コスト・工数）: 3-4 日

### Decision（決定）

**Chosen Option**（選択した選択肢）: TBD

**Rationale**（理由）:
<!-- チームでの議論により決定 -->

**Accepted Risks**（受け入れたリスク）:
- TBD

**Non-Negotiables**（譲れない点）:
- `/sdlc-init` の原則を厳守すること
- テンプレート構造の大幅な変更は避けること

### Impact（影響）

- **Technical**（技術的）: TBD
- **Team**（チーム）: TBD
- **Timeline**（タイムライン）: TBD
- **Cost**（コスト）: TBD

### Follow-up Actions（フォローアップアクション）

- [ ] 実装順序の確定
- [ ] テンプレート簡素化の着手

---

## Decision 2: test_plan.md の生成タイミング

**Status**: PENDING  
**Date**（日付）: 2025-12-29  
**Decision Maker**（意思決定者）: TBD

### Context（背景）

Issue では「一部の文書を『按需生成』に変更（例: `50_test_plan.md` は `/sdlc-test` 時に生成）」という提案がある。これにより初期生成される文書量を削減できる可能性がある。

### Options Considered（検討した選択肢）

#### Option A: `/sdlc-init` 時に生成（現在の動作）

**Pros**（長所）:
- 初期段階でテスト計画を検討できる
- 全体像を早期に把握可能
- 現在のワークフローを変更しない

**Cons**（短所）:
- 初期生成される文書量が多い
- 実装前にテスト詳細を決めるのは困難な場合がある

**Cost/Effort**（コスト・工数）: 変更なし

#### Option B: `/sdlc-test` 時に生成（按需生成）

**Pros**（長所）:
- 初期文書量を削減できる
- 実装完了後にテスト詳細を決められる
- より正確なテスト計画を作成できる

**Cons**（短所）:
- `/sdlc-test` コマンドの変更が必要
- ワークフローの変更により混乱の可能性
- テスト戦略の検討が後回しになるリスク

**Cost/Effort**（コスト・工数）: 中（`/sdlc-test` コマンドの修正が必要）

#### Option C: 簡素化して `/sdlc-init` 時に生成、詳細は `/sdlc-test` で追加

**Pros**（長所）:
- 初期段階でテスト戦略の概要を検討
- 詳細は実装完了後に追加
- ワークフローの大幅な変更を避けられる

**Cons**（短所）:
- 2 段階での生成が複雑
- どこまで初期生成するか判断が難しい

**Cost/Effort**（コスト・工数）: 中〜高

### Decision（決定）

**Chosen Option**（選択した選択肢）: TBD

**Rationale**（理由）:
<!-- チームでの議論により決定 -->

**Accepted Risks**（受け入れたリスク）:
- TBD

**Non-Negotiables**（譲れない点）:
- テスト品質を損なわないこと
- ワークフローが複雑化しすぎないこと

### Impact（影響）

- **Technical**（技術的）: TBD
- **Team**（チーム）: TBD
- **Timeline**（タイムライン）: TBD
- **Cost**（コスト）: TBD

### Follow-up Actions（フォローアップアクション）

- [ ] テスト計画の生成タイミング確定
- [ ] 必要に応じて `/sdlc-test` コマンドの修正

---

## Decision 3: 低リスク Feature の文書統合

**Status**: PENDING  
**Date**（日付）: 2025-12-29  
**Decision Maker**（意思決定者）: TBD

### Context（背景）

Issue では「低リスク Feature の文書統合を検討」という提案がある。現在、低リスクでも 3 ファイル（`00_context.md`, `decisions.md`, `risks.md`）が生成される。

### Options Considered（検討した選択肢）

#### Option A: 現在の 3 ファイル構成を維持

**Pros**（長所）:
- リスクレベル間で一貫した構造
- ファイルの役割が明確
- 既存ワークフローの変更不要

**Cons**（短所）:
- 低リスクには過剰な可能性
- 文書量削減効果が限定的

**Cost/Effort**（コスト・工数）: 変更なし

#### Option B: 1 ファイルに統合（例: `feature.md`）

**Pros**（長所）:
- 最も簡潔
- 低リスク Feature に適した軽量な構造
- 読みやすい

**Cons**（短所）:
- リスクレベル間で構造が異なる
- 将来的にリスクレベルが上がった場合の移行が困難
- SDLC コマンドの大幅な変更が必要

**Cost/Effort**（コスト・工数）: 高

#### Option C: 簡素化のみで統合はしない

**Pros**（長所）:
- 構造の一貫性を保持
- 最小限の変更で文書量を削減
- 将来の拡張が容易

**Cons**（短所）:
- 統合ほどの文書量削減効果はない

**Cost/Effort**（コスト・工数）: 低

### Decision（決定）

**Chosen Option**（選択した選択肢）: TBD

**Rationale**（理由）:
<!-- チームでの議論により決定 -->

**Accepted Risks**（受け入れたリスク）:
- TBD

**Non-Negotiables**（譲れない点）:
- リスクレベル間の一貫性を可能な限り保つこと
- SDLC コマンドの大幅な変更を避けること

### Impact（影響）

- **Technical**（技術的）: TBD
- **Team**（チーム）: TBD
- **Timeline**（タイムライン）: TBD
- **Cost**（コスト）: TBD

### Follow-up Actions（フォローアップアクション）

- [ ] 低リスク Feature の文書構成を確定
- [ ] 必要に応じてテンプレート構造の変更

---

## Decision History（決定履歴）

### Revisions（改訂）

（まだ改訂なし）

---

## Quick Reference（クイックリファレンス）

### All Confirmed Decisions（全確定済み決定）

（まだ確定済みの決定なし）

### Pending Decisions（保留中の決定）

1. **テンプレート簡素化の実装順序**: 検討中 - TBD
2. **test_plan.md の生成タイミング**: 検討中 - TBD
3. **低リスク Feature の文書統合**: 検討中 - TBD

---

## Notes（備考）

これらの Decision は Issue #41 の内容に基づいて作成されました。チームでの議論により、各 Decision の Status を CONFIRMED または REJECTED に更新してください。
