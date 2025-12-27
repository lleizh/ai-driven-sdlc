# Decisions

**Feature ID**: FEATURE-12  
**Last Updated**: 2025-12-26

---

## Decision 1: Implementation Plan タスク解析の実装方式

**Status**: CONFIRMED  
**Date**: 2025-12-26  
**Decision Maker**: lleizh

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

**Rejection Reason**: 将来的な拡張性が限定的

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

**Rejection Reason**: 既存 Plan の即時サポートができない、テンプレート変更による一時的な混乱

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
**Chosen Option**: Option C（両方を組み合わせ - 段階的アプローチ）

**Rationale**:
まず Option A で既存の Plan（FEATURE-7 など）をサポートし、将来的に Option B のテンプレート改善を実施する。これにより、既存の Implementation Plan との互換性を保ちながら、長期的に見て開発プロセスの標準化に貢献できる。段階的アプローチにより、各段階でのリスクを分散し、実際の使用経験を基に次の段階を最適化できる。

**Accepted Risks**:
- 2段階の実装が必要（工数増加）
- 複雑度がやや増す
- 将来的に既存 Plan を新テンプレートに更新する必要がある

**Non-Negotiables**:
- 既存の `/sdlc-check` の動作を破壊しない
- FEATURE-7 など既存の Implementation Plan でも動作すること（第1段階で対応）

### Impact
- **Technical**: 第1段階は柔軟なパースロジック、第2段階は構造化されたテンプレート
- **Team**: 第1段階は影響最小、第2段階で新テンプレートの学習が必要
- **Timeline**: 2段階実装のため、完全な標準化まで時間がかかる
- **Cost**: 中程度（段階的なので各段階のコストは抑えられる）

### Follow-up Actions
- [x] Decision の確定
- [ ] 第1段階: 既存 Plan 向けパースロジックの実装
- [ ] 第1段階: FEATURE-7 での動作確認
- [ ] 第2段階: 新テンプレート設計（Pre-PR Requirements セクション）
- [ ] 第2段階: 新規 Feature への適用

### Known Conflicts
⚠️ **Warning**: risks.md の R003 緩和策「柔軟なパースロジック実装」と最終的な目標（厳格なテンプレート）が軽微に不一致。ただし段階的アプローチにより、第1段階で柔軟なパース、第2段階で厳格なフォーマットという移行で整合性を確保。

---

## Decision 2: タスクカテゴリの判定方法

**Status**: CONFIRMED  
**Date**: 2025-12-26  
**Decision Maker**: lleizh

### Context
未完了タスクをカテゴリ別に分類する必要がある（Documentation、Testing、Core 実装など）。どのようにカテゴリを判定するか。Decision 1 で段階的アプローチを選択したため、各段階に適した判定方法を選択する。

### Options Considered

#### Option A: キーワードベースの判定
**Pros**:
- 実装がシンプル（grep で "README", "test", "doc" などをチェック）
- 既存の Implementation Plan に即座に適用可能

**Cons**:
- 判定精度が低い可能性
- キーワードのメンテナンスが必要

**Cost/Effort**: 低

**Rejection Reason**: 判定精度が低く、誤検出のリスクが高い

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

**Rejection Reason**: 過度に複雑で、開発者の柔軟性を損なう

### Decision
**Chosen Option**: Option B（Implementation Plan にタスクカテゴリを明記）

**Rationale**:
長期的に見て、開発プロセスの標準化に貢献する。Decision 1 で段階的アプローチを選択したため、第1段階ではキーワードベースの簡易判定を実装し、第2段階で Option B（カテゴリ明記）を導入する。これにより、既存 Plan への即時対応と将来的な精度向上の両立が可能。

**Accepted Risks**:
- 既存の Implementation Plan を全て更新する必要がある（工数）
- 開発者がカテゴリを明記する新しいルールを学習する必要がある

**Non-Negotiables**:
- 少なくとも Documentation と Testing タスクは識別できること

### Impact
- **Technical**: 第2段階でテンプレート変更が必要
- **Team**: 新しいカテゴリ明記ルールの学習が必要
- **Timeline**: 第2段階での展開まで時間がかかる
- **Cost**: 中程度（既存 Plan の更新コスト）

### Follow-up Actions
- [x] Decision の確定
- [ ] 第1段階: キーワードベースの簡易判定を実装（暫定措置）
- [ ] 第2段階: カテゴリ明記ルールの設計
- [ ] 第2段階: テンプレートへのカテゴリフィールド追加
- [ ] 第2段階: 開発者向けガイドラインの作成

---

## Quick Reference

### All Confirmed Decisions
1. **Implementation Plan タスク解析の実装方式**: Option C（段階的アプローチ） - 2025-12-26
2. **タスクカテゴリの判定方法**: Option B（カテゴリ明記） - 2025-12-26

### Pending Decisions
（全ての Decision が確定しました）

---

## Decision History

### Confirmations

#### Decision 1: Implementation Plan タスク解析の実装方式
**Confirmed**: 2025-12-26 - Option C  
**Decision Maker**: lleizh  
**Key Rationale**: 既存 Plan との互換性を保ちながら、段階的に標準化を進める

#### Decision 2: タスクカテゴリの判定方法
**Confirmed**: 2025-12-26 - Option B  
**Decision Maker**: lleizh  
**Key Rationale**: 長期的な開発プロセスの標準化に貢献

---

## Notes
両方の Decision は関連しており、段階的アプローチで一貫性を保つ：
- **第1段階（短期）**: 既存 Plan 向けの柔軟なパースロジック + キーワードベース判定
- **第2段階（長期）**: 新テンプレート（Pre-PR Requirements） + カテゴリ明記
