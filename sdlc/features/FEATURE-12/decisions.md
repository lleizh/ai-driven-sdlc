# Decisions

**Feature ID**: FEATURE-12  
**Last Updated**: 2025-12-26

---

## Decision 1: Implementation Plan タスク解析の実装方式

**Status**: PENDING  
**Date**: 2025-12-26  
**Decision Maker**: TBD

### Context
`/sdlc-check` コマンドに Implementation Plan のタスク解析機能を追加する必要がある。Issue では2つのアプローチが提示されている。

### Options Considered

#### Option A: Implementation Plan のパースを直接追加
**Pros**:
- 既存の `/sdlc-check` に直接チェックロジックを追加するだけでシンプル
- テンプレート変更不要で既存の Implementation Plan にも適用可能
- 実装コストが低い

**Cons**:
- パースロジックが複雑になる可能性（カテゴリの判定など）
- 将来的な拡張性が限定的

**Cost/Effort**: 低（数時間の実装）

#### Option B: Implementation Plan テンプレートに「Pre-PR Requirements」セクションを追加
**Pros**:
- チェック対象が明確（Pre-PR Requirements セクションを検証するだけ）
- パースロジックがシンプル
- 将来的な拡張が容易

**Cons**:
- テンプレート変更が必要
- 既存の Implementation Plan を全て更新する必要がある
- 実装コストがやや高い

**Cost/Effort**: 中（テンプレート更新 + パースロジック実装）

#### Option C: 両方を組み合わせ（段階的アプローチ）
**Pros**:
- まず Option A で既存の Plan をサポート
- 将来的に Option B のテンプレート改善も実施
- 互換性を保ちながら段階的に改善できる

**Cons**:
- 2段階の実装が必要
- 複雑度がやや増す

**Cost/Effort**: 中〜高（段階的実装）

### Decision
**Chosen Option**: PENDING（チームでの議論が必要）

**Rationale**:
<!-- なぜこの選択をしたのか -->

**Accepted Risks**:
- 

**Non-Negotiables**:
- 既存の `/sdlc-check` の動作を破壊しない
- FEATURE-7 など既存の Implementation Plan でも動作すること

### Impact
- **Technical**: パースロジックの実装方式に影響
- **Team**: 選択によっては既存 Plan の更新作業が発生
- **Timeline**: Option A は最短、Option B/C はやや長め
- **Cost**: Option A が最も低コスト

### Follow-up Actions
- [ ] チームでの選択肢の議論
- [ ] 選択後、実装計画の作成

---

## Decision 2: タスクカテゴリの判定方法

**Status**: PENDING  
**Date**: 2025-12-26  
**Decision Maker**: TBD

### Context
未完了タスクをカテゴリ別に分類する必要がある（Documentation、Testing、Core 実装など）。どのようにカテゴリを判定するか。

### Options Considered

#### Option A: キーワードベースの判定
**Pros**:
- 実装がシンプル（grep で "README", "test", "doc" などをチェック）
- 既存の Implementation Plan に即座に適用可能

**Cons**:
- 判定精度が低い可能性
- キーワードのメンテナンスが必要

**Cost/Effort**: 低

#### Option B: Implementation Plan にタスクカテゴリを明記
**Pros**:
- 判定精度が高い
- 開発者が明示的にカテゴリを指定するため誤分類が少ない

**Cons**:
- テンプレート変更が必要
- 既存 Plan の更新が必要

**Cost/Effort**: 中

#### Option C: セクション構造で判定
**Pros**:
- Implementation Plan のセクション名（## Documentation Tasks など）で判定
- 構造化されたアプローチ

**Cons**:
- テンプレートの構造変更が必要
- 既存 Plan への適用が困難

**Cost/Effort**: 高

### Decision
**Chosen Option**: PENDING（Decision 1 の結果に依存）

**Rationale**:


**Accepted Risks**:


**Non-Negotiables**:
- 少なくとも Documentation と Testing タスクは識別できること

### Impact
- **Technical**: パースロジックの複雑度に影響
- **Team**: Option B/C の場合、Plan 記載方法の変更が必要
- **Timeline**: 
- **Cost**: 

### Follow-up Actions
- [ ] Decision 1 の確定後に判定

---

## Quick Reference

### All Confirmed Decisions
（まだ確定した Decision はありません）

### Pending Decisions
1. **Implementation Plan タスク解析の実装方式**: Option A/B/C の選択待ち
2. **タスクカテゴリの判定方法**: Option A/B/C の選択待ち

---

## Notes
両方の Decision は関連しているため、一緒に議論・決定することを推奨。
