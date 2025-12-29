# /sdlc-revise - Refined Flow Analysis

## コマンド概要
実装中に設計の前提が崩れた場合、Decision を修正し影響範囲を記録します

## 使用方法
```bash
/sdlc-revise <feature-id>
```

**入力情報**:
- Why Revise（なぜ変更が必要か）
- What Changed（何を変更したか）
- Impact Scope（影響範囲）
- New Risks（新しく発生したリスク）
- Decision Maker（名前）

## 現在の構造
- **ステップ数**: 7
- **共有スクリプト使用**: ❌ 未使用
- **前提確認**: ❌ 不完全（共有スクリプトなし）
- **複雑度**: 非常に高い（253行、最長）

---

## 詳細フロー

### Step 1: 前提確認

**目的**: Feature 存在、ブランチ、Decision Status の確認

**実行内容**:
```bash
source scripts/common-functions.sh

# Feature 存在確認
check_feature_exists "$FEATURE_ID" || exit 1

# ブランチ確認
scripts/check-branch.sh "$FEATURE_ID" || exit 1

# Decision Status 確認
DECISION_STATUS=$(get_metadata_value "$FEATURE_ID" "DECISION_STATUS")

if [[ "$DECISION_STATUS" != "confirmed" ]]; then
    display_error \
        "Decisions が CONFIRMED ではありません" \
        "現在: ${DECISION_STATUS}" \
        "/sdlc-decision ${FEATURE_ID} で Decision を確定してください"
    exit 1
fi

# 実装フェーズであることを確認
STATUS=$(get_metadata_value "$FEATURE_ID" "STATUS")
if [[ "$STATUS" != "implementing" && "$STATUS" != "testing" ]]; then
    display_error \
        "実装フェーズではありません" \
        "現在: ${STATUS}" \
        "Revision は実装中にのみ使用できます"
    exit 1
fi
```

**共有スクリプト**:
- `check_feature_exists()` - Feature 存在確認
- `scripts/check-branch.sh` - ブランチ検証
- `get_metadata_value()` - Metadata 値取得
- `display_error()` - エラー表示

---

### Step 2: ユーザー入力を収集

**目的**: Revision に必要な情報を取得

**収集する情報**:
```bash
# ユーザーから入力を受け取る
read -p "Why Revise (変更理由): " WHY_REVISE
read -p "What Changed (変更内容): " WHAT_CHANGED
read -p "Impact Scope (影響範囲): " IMPACT_SCOPE
read -p "New Risks (新リスク, カンマ区切り): " NEW_RISKS
read -p "Decision Maker (名前): " DECISION_MAKER

# Revision 番号を取得
REVISION_COUNT=$(get_metadata_value "$FEATURE_ID" "REVISION_COUNT" || echo "0")
REVISION_NUM=$((REVISION_COUNT + 1))
```

---

### Step 3: decisions.md を更新

**目的**: REVISED エントリを追加

**実行内容**:
```bash
DECISIONS_FILE="sdlc/features/${FEATURE_ID}/decisions.md"

# REVISED エントリを追記（元の CONFIRMED は残す）
REVISED_ENTRY="
---

## Decision Revision ${REVISION_NUM}

**Status**: REVISED
**Date**: $(date +%Y-%m-%d)
**Decision Maker**: ${DECISION_MAKER}

### Why Revise（変更理由）
${WHY_REVISE}

### What Changed（変更内容）
${WHAT_CHANGED}

### Impact Scope（影響範囲）
${IMPACT_SCOPE}

### Accepted Risks
${NEW_RISKS}
"

# Write ツールで追記
```

---

### Step 4: risks.md を更新

**目的**: New Risks がある場合、risks.md に追加

**実行内容**:
```bash
if [[ -n "$NEW_RISKS" ]]; then
    RISKS_FILE="sdlc/features/${FEATURE_ID}/risks.md"
    
    # Risk 詳細を追加
    # - "Detailed Risk Analysis" セクションに追加
    # - "Introduced By: Decision Revision #${REVISION_NUM}" を含める
    # - Risk Assessment Summary テーブルも更新
fi
```

---

### Step 5: impl_plan.md を更新

**目的**: Revision Alert を追加

**実行内容**:
```bash
IMPL_PLAN="sdlc/features/${FEATURE_ID}/30_implementation_plan.md"

if [[ -f "$IMPL_PLAN" ]]; then
    # ファイル冒頭に Alert を追加
    ALERT="
> ⚠️ **Revision Alert**: This plan was revised on $(date +%Y-%m-%d) due to design changes.  
> See [Decision Revision #${REVISION_NUM}](decisions.md#decision-revision-${REVISION_NUM}) for details.
"
    # Write ツールで更新
fi
```

---

### Step 6: design.md を更新

**目的**: Status を REVISED に変更し、Revision History を追加

**実行内容**:
```bash
DESIGN_FILE="sdlc/features/${FEATURE_ID}/20_design.md"

if [[ -f "$DESIGN_FILE" ]]; then
    # Status 更新: APPROVED → REVISED
    # Edit ツールで置換
    
    # Revision History を追加（ファイル末尾）
    REVISION_HISTORY="
---

## Revision History

### Revision #${REVISION_NUM} - $(date +%Y-%m-%d)
**Decision Maker**: ${DECISION_MAKER}  
**Reason**: ${WHY_REVISE}  
**Changes**: ${WHAT_CHANGED}  
**Impact Scope**: ${IMPACT_SCOPE}  
**Related Decision**: [Decision Revision #${REVISION_NUM}](decisions.md#decision-revision-${REVISION_NUM})
"
    # Write ツールで追加
fi
```

---

### Step 7: メタデータ更新

**目的**: STATUS を blocked に変更し、Revision 情報を記録

**実行内容**:
```bash
# 現在の STATUS を保存
CURRENT_STATUS=$(get_metadata_value "$FEATURE_ID" "STATUS")

# Metadata 更新
scripts/update-metadata.sh "$FEATURE_ID" "PREVIOUS_STATUS" "$CURRENT_STATUS"
scripts/update-metadata.sh "$FEATURE_ID" "STATUS" "blocked"
scripts/update-metadata.sh "$FEATURE_ID" "BLOCKED_REASON" "Decision revision pending review"
scripts/update-metadata.sh "$FEATURE_ID" "BLOCKED_DATE" "$(date +%Y-%m-%d)"
scripts/update-metadata.sh "$FEATURE_ID" "REVISION_COUNT" "$REVISION_NUM"
scripts/update-metadata.sh "$FEATURE_ID" "REVISION_${REVISION_NUM}_DATE" "$(date +%Y-%m-%d)"
scripts/update-metadata.sh "$FEATURE_ID" "REVISION_${REVISION_NUM}_MAKER" "$DECISION_MAKER"
scripts/update-metadata.sh "$FEATURE_ID" "REVISION_${REVISION_NUM}_REASON" "${WHY_REVISE:0:50}"
scripts/update-metadata.sh "$FEATURE_ID" "DECISION_STATUS" "revised"
scripts/update-metadata.sh "$FEATURE_ID" "LAST_UPDATED" "$(date +%Y-%m-%d)"
```

**共有スクリプト**:
- `scripts/update-metadata.sh` - Metadata 更新
- `get_metadata_value()` - Metadata 値取得

---

### Step 8: Commit & Push

**目的**: すべての変更を commit & push

**実行内容**:
```bash
ISSUE_NUMBER=$(get_metadata_value "$FEATURE_ID" "ISSUE_URL" | grep -oE '[0-9]+$')

git add "sdlc/features/${FEATURE_ID}/"

git commit -m "docs(${FEATURE_ID}): Decision Revision #${REVISION_NUM}

${WHY_REVISE}

Decision Maker: ${DECISION_MAKER}
Impact Scope: ${IMPACT_SCOPE}

Related: #${ISSUE_NUMBER}"

git push origin "feature/${FEATURE_ID}"
```

**共有スクリプト**:
- `get_metadata_value()` - Metadata 値取得

---

**完了メッセージ**（出力のみ、ステップではない）:
```
✅ Decision Revision ${REVISION_NUM} を記録しました

📋 更新されたファイル:
- decisions.md (REVISED エントリ追加)
- risks.md (新リスク追加)
- 30_implementation_plan.md (Revision Alert)
- 20_design.md (Status: REVISED)
- .metadata (STATUS=blocked)

⚠️ 実装を一時停止してください

現在の状態:
- STATUS: blocked
- PREVIOUS_STATUS: ${CURRENT_STATUS}
- DECISION_STATUS: revised

次のアクション:
【大きな変更】
1. Revision PR をチームレビュー
2. PR マージ後: /sdlc-resume ${FEATURE_ID}

【小さな変更】
1. チームに変更内容を共有
2. 確認後: /sdlc-resume ${FEATURE_ID}
```

---

## 最適化提案

### 現在の問題点

1. **共有スクリプト未使用**:
   - `check_feature_exists()` を使うべき
   - `check-branch.sh` を使うべき
   - Metadata 更新に直接書き込みではなく `update-metadata.sh` を使うべき

2. **ステップの粒度**:
   - Step 3 "関連ファイルを更新" が複雑すぎる（4ファイル更新）
   - 各ファイル更新を独立したステップに分離すべき

3. **入力収集**:
   - ユーザー入力の収集が明示されていない

4. **完了メッセージ**:
   - 独立したステップとしてカウントされている

### 最適化案

**7 Steps → 8 Steps**

```
1. 前提確認（Feature 存在 + ブランチ確認 + Decision Status + 実装フェーズ確認）
2. ユーザー入力を収集（Why/What/Impact/NewRisks/Maker）
3. decisions.md を更新（REVISED エントリ追加）
4. risks.md を更新（New Risks がある場合）
5. impl_plan.md を更新（Revision Alert 追加）
6. design.md を更新（Status: REVISED、Revision History）
7. メタデータ更新（STATUS=blocked、Revision 情報）
8. Commit & Push
```

**変更内容**:
- 前提確認に共有スクリプトを使用
- ユーザー入力収集を独立ステップに
- ファイル更新を分離（decisions, risks, impl_plan, design, metadata）
- Metadata 更新に `update-metadata.sh` を使用
- PR 作成を削除（ユーザーが手動で行う）
- "完了メッセージ" を削除（出力のみ）

---

## エラーハンドリング

| エラー状況 | 処理 | 使用機能 |
|-----------|------|---------|
| Feature 不存在 | エラー表示して終了 | `check_feature_exists()` |
| ブランチ不一致 | エラー表示して終了 | `check-branch.sh` |
| Decision 未確定 | エラー表示 | `get_metadata_value()` |
| 実装フェーズ外 | エラー表示 | `get_metadata_value()` |
| 入力不足 | 再入力を促す | - |

---

## 共有スクリプト活用状況

❌ **未使用** - 共有スクリプトを使用していない

**追加すべき共有スクリプト**:
- `check_feature_exists()` - Feature 存在確認
- `scripts/check-branch.sh` - ブランチ検証
- `get_metadata_value()` - Metadata 値取得
- `display_error()` - エラー表示
- `scripts/update-metadata.sh` - Metadata 更新（複数フィールド）

**sed/直接書き込み使用**: ⚠️ あり（metadata を直接書き込み）

---

## 特殊性

**このコマンドの特殊性**:
- 最も複雑なコマンド（253行）
- 5つのファイルを更新（decisions, risks, impl_plan, design, metadata）
- STATUS を blocked に変更（唯一）
- Revision 履歴を記録
- 条件付き PR 作成

**Revision 頻度の目安**:
- 0-1回: 健全
- 2-3回: 要注意
- 4回以上: 設計の根本的な見直しが必要

---

## いつ使うべきか

✅ **使うべき場合**:
- 技術的制約が後から判明
- 外部サービスの仕様変更
- 実装中に設計の欠陥が判明

❌ **使わない場合**:
- 単なるリファクタリング
- 新機能の追加（スコープクリープ）
- 軽微なバグ修正

---

## 結論

**現状**: 最も複雑なコマンドだが、共有スクリプトを全く使用していない

**推奨変更**:
1. 前提確認に共有スクリプトを使用
2. ファイル更新を明確なステップに分離
3. Metadata 更新に `update-metadata.sh` を使用
4. "完了メッセージ" を削除（出力のみ）

**最終ステップ数**: 7 → **8**

**複雑度**: 非常に高い（5ファイル更新）
