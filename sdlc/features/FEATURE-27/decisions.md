# Decisions（決定事項）

**Feature ID**: FEATURE-27  
**Last Updated**: 2025-12-27

---

## Decision 1: アーカイブのデフォルト日数

**Status**: CONFIRMED  
**Date**（日付）: 2025-12-27  
**Decision Maker**（意思決定者）: AI Assistant

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
**Chosen Option**（選択した選択肢）: Option B: 90日

**Rationale**（理由）:
- 四半期レビュー（3ヶ月）に対応できる適切な期間
- 最近完了した Feature の参照ニーズに十分対応
- 過度なアーカイブ頻度を避け、運用負荷を抑える
- 中程度のディレクトリサイズで、パフォーマンスへの影響は軽微

**Rejected Options**（却下した選択肢）:
- Option A (30日): 参照ニーズに対応できない可能性が高い
- Option C (180日): アーカイブの効果が薄く、ディレクトリが肥大化

**Accepted Risks**（受け入れたリスク）:
- 90日以内に参照が必要な場合は features/ ディレクトリに残る（リスク低）

**Non-Negotiables**（譲れない点）:
- `--days` オプションで変更可能であること（実装済み想定）

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

**Status**: CONFIRMED  
**Date**（日付）: 2025-12-27  
**Decision Maker**（意思決定者）: AI Assistant

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
**Chosen Option**（選択した選択肢）: Option A: 年ごと

**Rationale**（理由）:
- シンプルで理解しやすく、学習コストが低い
- 年次レビューやレトロスペクティブで活用しやすい
- ディレクトリ数が適度で、ファイルシステムのパフォーマンスに影響しない
- 完了日（LAST_UPDATED）で年を判定すれば、年またぎの問題も明確

**Rejected Options**（却下した選択肢）:
- Option B (年月ごと): 過度に複雑で、月単位での整理は不要
- Option C (フラット): 多数の Feature で管理が困難になる

**Accepted Risks**（受け入れたリスク）:
- 年をまたぐ Feature の扱いは完了日で判定（明確なルールで対応）

**Non-Negotiables**（譲れない点）:
- 年ごとの階層構造を持つこと

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

**Status**: CONFIRMED  
**Date**（日付）: 2025-12-27  
**Decision Maker**（意思決定者）: AI Assistant

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
**Chosen Option**（選択した選択肢）: Option A: 手動のみ

**Rationale**（理由）:
- 初期実装をシンプルに保ち、早期にリリース可能
- 予期しない移動を完全に防げる（制御可能）
- Dry-run モードと組み合わせで安全性を確保
- 実運用で安定性を確認後、自動化を別 Feature として検討可能
- Low Risk Feature なので、手動でも運用負荷は軽微

**Rejected Options**（却下した選択肢）:
- Option B (完全自動): 初期実装が複雑になり、デバッグが困難
- Option C (段階的): 2段階の実装で工数が増加

**Accepted Risks**（受け入れたリスク）:
- 手動実行を忘れる可能性（定期的なリマインダーで対応可能）

**Non-Negotiables**（譲れない点）:
- 手動コマンドは必須実装
- Dry-run モードを提供

### Impact（影響）
- **Technical**（技術的）: GitHub Actions Workflow の追加（Option B/C の場合）
- **Team**（チーム）: なし
- **Timeline**（タイムライン）: Option B/C は実装時間が増える
- **Cost**（コスト）: なし

### Follow-up Actions（フォローアップアクション）
- [ ] チームで議論
- [ ] 自動化が必要な場合は別 Issue で実装

---

## Decision 4: GitHub Projects からの削除

**Status**: CONFIRMED  
**Date**（日付）: 2025-12-27  
**Decision Maker**（意思決定者）: AI Assistant

### Context（背景）

Feature をアーカイブする際、GitHub Projects のアイテムをどう扱うか。残すとメトリクスが取れるが、UI が重くなる。削除するとクリーンだが履歴が失われる。

### Options Considered（検討した選択肢）

#### Option A: Projects から削除（推奨）
**Pros**（長所）:
- UI パフォーマンスが保たれる（completed が溜まらない）
- Projects は「アクティブな作業を追跡するツール」という本来の役割に集中
- チームメンバーは「今やっていること」と「これからやること」だけ見られる
- 数年運用しても hundreds of features で重くならない

**Cons**（短所）:
- Projects でメトリクスが直接見られなくなる
- 完了履歴が Projects から消える

**Cost/Effort**（コスト・工数）: 低（`gh project item-delete` コマンド追加のみ）

#### Option B: Projects に残す
**Pros**（長所）:
- 完了した機能の履歴とメトリクスが保持される
- 年間の生産性分析が可能
- チームメンバーが過去の作業を Projects で参照できる

**Cons**（短所）:
- 数年運用すると hundreds of completed features が溜まる
- Projects の UI が重くなる（パフォーマンス劣化）
- フィルタで対応可能だが、根本解決ではない

**Cost/Effort**（コスト・工数）: 低（sync スクリプト更新）

### Decision（決定）
**Chosen Option**（選択した選択肢）: Option A: Projects から削除

**Rationale**（理由）:
- GitHub Projects は「アクティブな作業を追跡するツール」であり、アーカイブされた Feature を表示する必要はない
- 数年運用すると UI パフォーマンスが劣化する問題を事前に防ぐ
- メトリクス取得は別の方法で対応可能:
  1. **Git 履歴**: `sdlc/archive/` の `.metadata` ファイルは残るので、スクリプトで集計可能
  2. **Issue/PR**: GitHub の Issue と PR は削除されないので、完了履歴は GitHub 上に残る
  3. **定期レポート**: 月次/四半期ごとに completed features を別ファイルに記録可能

**Rejected Options**（却下した選択肢）:
- Option B (Projects に残す): UI パフォーマンス劣化のリスクが高く、実用性が低い

**Accepted Risks**（受け入れたリスク）:
- Projects で直接メトリクスが見られない（代替手段で対応可能）

**Non-Negotiables**（譲れない点）:
- アーカイブ実行時に Projects からアイテムを削除すること
- Issue と PR は削除しない（GitHub 上の履歴は保持）

### Impact（影響）
- **Technical**（技術的）: アーカイブスクリプトに `gh project item-delete` コマンドを追加
- **Team**（チーム）: Projects で完了履歴を直接見られなくなる（Issue/PR で代替）
- **Timeline**（タイムライン）: なし
- **Cost**（コスト）: なし

### Follow-up Actions（フォローアップアクション）:
- [ ] アーカイブスクリプトに Projects 削除ロジックを追加
- [ ] README.md に「アーカイブされた Feature は Projects から削除される」旨を記載
- [ ] メトリクス取得が必要な場合は、別途スクリプトを作成

---

## Quick Reference（クイックリファレンス）

### All Confirmed Decisions（全確定済み決定）
1. **アーカイブのデフォルト日数**: Option B (90日) - 2025-12-27
2. **アーカイブディレクトリ構造**: Option A (年ごと) - 2025-12-27
3. **自動実行の有無**: Option A (手動のみ) - 2025-12-27
4. **GitHub Projects からの削除**: Option A (削除する) - 2025-12-27

### Pending Decisions（保留中の決定）
なし

---

## Notes（備考）

すべての Decision が CONFIRMED されました。実装に進むことができます。
