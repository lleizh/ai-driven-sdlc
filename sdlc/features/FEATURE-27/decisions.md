# Decisions（決定事項）

**Feature ID**: FEATURE-27  
**Last Updated**: 2025-12-27

---

## Decision 1: アーカイブのデフォルト日数

**Status**: PENDING  
**Date**（日付）: 2025-12-27  
**Decision Maker**（意思決定者）: TBD

### Context（背景）

完了した Feature をいつアーカイブするかの基準が必要。短すぎると最近の参照が難しくなり、長すぎるとディレクトリが肥大化する。

### Options Considered（検討した選択肢）

#### Option A: 30日
**Pros**（長所）:
- ディレクトリが常にクリーンに保たれる
- 最近の完了 Feature のみが残る

**Cons**（短所）:
- 最近の参照ニーズに対応できない可能性
- 頻繁にアーカイブ操作が必要

**Cost/Effort**（コスト・工数）: 低

#### Option B: 90日（推奨）
**Pros**（長所）:
- 約3ヶ月分の履歴が残る（四半期レビューに対応）
- 最近の参照ニーズに十分対応
- 過度なアーカイブ頻度を避けられる

**Cons**（短所）:
- 中程度のディレクトリサイズ

**Cost/Effort**（コスト・工数）: 低

#### Option C: 180日
**Pros**（長所）:
- 半年分の履歴が残る
- アーカイブ頻度が最小

**Cons**（短所）:
- ディレクトリが比較的大きくなる
- 長期間アクティブディレクトリに残る

**Cost/Effort**（コスト・工数）: 低

### Decision（決定）
**Chosen Option**（選択した選択肢）: TBD

**Rationale**（理由）:
チームで議論して決定

**Accepted Risks**（受け入れたリスク）:
- TBD

**Non-Negotiables**（譲れない点）:
- `--days` オプションで変更可能であること

### Impact（影響）
- **Technical**（技術的）: コマンドのデフォルト値のみに影響
- **Team**（チーム）: なし
- **Timeline**（タイムライン）: なし
- **Cost**（コスト）: なし

### Follow-up Actions（フォローアップアクション）
- [ ] チームで議論
- [ ] README.md にデフォルト値を記載

---

## Decision 2: アーカイブディレクトリ構造

**Status**: PENDING  
**Date**（日付）: 2025-12-27  
**Decision Maker**（意思決定者）: TBD

### Context（背景）

アーカイブされた Feature をどう整理するか。フラットな構造だと探しにくく、階層構造だと管理しやすい。

### Options Considered（検討した選択肢）

#### Option A: 年ごと（推奨）
```
sdlc/archive/
├── 2024/
│   ├── FEATURE-100/
│   └── FEATURE-101/
└── 2025/
    ├── FEATURE-120/
    └── FEATURE-123/
```

**Pros**（長所）:
- シンプルで理解しやすい
- 年次レビューに対応
- ディレクトリ数が適度

**Cons**（短所）:
- 年をまたぐ Feature の扱い（完了日で判定）

**Cost/Effort**（コスト・工数）: 低

#### Option B: 年月ごと
```
sdlc/archive/
├── 2025/
│   ├── 01/
│   ├── 02/
│   └── 03/
```

**Pros**（長所）:
- より細かい整理
- 月次レポートに対応

**Cons**（短所）:
- ディレクトリが多くなる
- やや複雑

**Cost/Effort**（コスト・工数）: 中

#### Option C: フラット
```
sdlc/archive/
├── FEATURE-100/
├── FEATURE-101/
└── FEATURE-120/
```

**Pros**（長所）:
- 最もシンプル

**Cons**（短所）:
- 多数の Feature で探しにくくなる
- 整理されていない印象

**Cost/Effort**（コスト・工数）: 低

### Decision（決定）
**Chosen Option**（選択した選択肢）: TBD

**Rationale**（理由）:
チームで議論して決定

**Accepted Risks**（受け入れたリスク）:
- TBD

**Non-Negotiables**（譲れない点）:
- 何らかの階層構造を持つこと

### Impact（影響）
- **Technical**（技術的）: ディレクトリ作成ロジックに影響
- **Team**（チーム）: なし
- **Timeline**（タイムライン）: なし
- **Cost**（コスト）: なし

### Follow-up Actions（フォローアップアクション）
- [ ] チームで議論
- [ ] README.md に構造を記載

---

## Decision 3: 自動実行の有無

**Status**: PENDING  
**Date**（日付）: 2025-12-27  
**Decision Maker**（意思決定者）: TBD

### Context（背景）

アーカイブを手動実行するか、GitHub Actions で自動実行するか。

### Options Considered（検討した選択肢）

#### Option A: 手動のみ（初期実装推奨）
**Pros**（長所）:
- シンプルで制御しやすい
- 予期しない移動を防げる
- 初期実装が早い

**Cons**（短所）:
- 実行を忘れる可能性
- 手動オペレーションが必要

**Cost/Effort**（コスト・工数）: 低

#### Option B: GitHub Actions 自動実行
**Pros**（長所）:
- 完全自動化
- 実行忘れがない

**Cons**（短所）:
- 追加の Workflow ファイルが必要
- デバッグが難しい
- 初期実装に時間がかかる

**Cost/Effort**（コスト・工数）: 中

#### Option C: 段階的（手動 → 自動）
**Pros**（長所）:
- 初期は手動で検証
- 安定後に自動化
- リスク最小

**Cons**（短所）:
- 2段階の実装が必要

**Cost/Effort**（コスト・工数）: 中

### Decision（決定）
**Chosen Option**（選択した選択肢）: TBD

**Rationale**（理由）:
チームで議論して決定

**Accepted Risks**（受け入れたリスク）:
- TBD

**Non-Negotiables**（譲れない点）:
- 手動コマンドは必須実装

### Impact（影響）
- **Technical**（技術的）: GitHub Actions Workflow の追加（Option B/C の場合）
- **Team**（チーム）: なし
- **Timeline**（タイムライン）: Option B/C は実装時間が増える
- **Cost**（コスト）: なし

### Follow-up Actions（フォローアップアクション）
- [ ] チームで議論
- [ ] 自動化が必要な場合は別 Issue で実装

---

## Quick Reference（クイックリファレンス）

### All Confirmed Decisions（全確定済み決定）
（まだ確定された決定はありません）

### Pending Decisions（保留中の決定）
1. **アーカイブのデフォルト日数**: Awaiting team discussion - TBD
2. **アーカイブディレクトリ構造**: Awaiting team discussion - TBD
3. **自動実行の有無**: Awaiting team discussion - TBD

---

## Notes（備考）

すべての Decision は PENDING 状態です。チームで議論して CONFIRMED に更新してください。
