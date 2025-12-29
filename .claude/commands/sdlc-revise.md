---
description: 実装中に設計の前提が崩れた場合、Decision を修正し影響範囲を記録する
---

# Command: /sdlc-revise

実装中に設計の前提が崩れた場合、Decision を修正し影響範囲を記録します。

## 使用方法

```
/sdlc-revise <feature-id>
```

実行時、以下の情報を入力してください：
- **Why Revise**（なぜ変更が必要か）
- **What Changed**（何を変更したか）
- **Impact Scope**（影響範囲：ファイル/モジュール名）
- **New Risks**（新しく発生したリスク）
- **Decision Maker**（あなたの名前）

## 実行内容

### 1. 前提確認

**共有スクリプトを使用**：
```bash
source scripts/common-functions.sh

# Feature 存在確認
check_feature_exists "$FEATURE_ID" || exit 1

# ブランチ検証
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

### 2. ユーザー入力を収集

以下の情報を収集：
```bash
read -p "Why Revise (変更理由): " WHY_REVISE
read -p "What Changed (変更内容): " WHAT_CHANGED
read -p "Impact Scope (影響範囲): " IMPACT_SCOPE
read -p "New Risks (新リスク, カンマ区切り): " NEW_RISKS
read -p "Decision Maker (名前): " DECISION_MAKER

# Revision 番号を取得
REVISION_COUNT=$(get_metadata_value "$FEATURE_ID" "REVISION_COUNT" || echo "0")
REVISION_NUM=$((REVISION_COUNT + 1))
```

### 3. decisions.md を更新

`decisions.md` に REVISED エントリを**追記**（元の CONFIRMED は残す）：

```markdown
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
```

### 4. risks.md を更新

New Risks がある場合、`risks.md` に追加：

**追加位置**: "Detailed Risk Analysis" セクションの末尾

**追加フィールド**: 
```markdown
**Introduced By**: Decision Revision #${REVISION_NUM}
```

**同時更新**: ファイル冒頭の "Risk Assessment Summary" テーブルにも新行を追加

### 5. impl_plan.md を更新

`30_implementation_plan.md` が存在する場合、ファイル冒頭に Revision Alert を追加：

```markdown
> ⚠️ **Revision Alert**: This plan was revised on $(date +%Y-%m-%d) due to design changes.  
> See [Decision Revision #${REVISION_NUM}](decisions.md#decision-revision-${REVISION_NUM}) for details.
```

**複数回 Revision の場合**: 既存の Alert の下に追加

### 6. design.md を更新

`20_design.md` が存在する場合：

**Status を更新**:
```markdown
**Status**: APPROVED → REVISED
```

**Revision History を追加**（ファイル末尾）:
```markdown
---

## Revision History

### Revision #${REVISION_NUM} - $(date +%Y-%m-%d)
**Decision Maker**: ${DECISION_MAKER}  
**Reason**: ${WHY_REVISE}  
**Changes**: ${WHAT_CHANGED}  
**Impact Scope**: ${IMPACT_SCOPE}  
**Related Decision**: [Decision Revision #${REVISION_NUM}](decisions.md#decision-revision-${REVISION_NUM})
```

**複数回 Revision の場合**: 新しいエントリを末尾に追加

### 7. メタデータ更新

**共有スクリプトを使用**：
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

### 8. Commit & Push

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

---

## 完了後の次のステップ

**大きな変更の場合**：
1. Revision PR をチームレビュー
2. PR マージ後: `/sdlc-resume {FEATURE_ID}`

**小さな変更の場合**：
1. チームに変更内容を共有
2. 確認後: `/sdlc-resume {FEATURE_ID}`

---

## 共有スクリプトの活用

このコマンドは以下の共有機能を使用：
- `check_feature_exists()` - Feature 存在確認
- `check-branch.sh` - ブランチ検証
- `get_metadata_value()` - Metadata 値取得
- `display_error()` - エラー表示
- `update-metadata.sh` - Metadata 更新

---

## 特徴

**このコマンドの特殊性**：
- 最も複雑なコマンド（5ファイル更新）
- STATUS を blocked に変更（唯一）
- Revision 履歴を記録
- 実装フェーズでのみ使用可能

**Revision 頻度の目安**：
- 0-1回: 健全
- 2-3回: 要注意
- 4回以上: 設計の根本的な見直しが必要

---

## いつ使うべきか

✅ **使うべき場合**：
- 技術的制約が後から判明
- 外部サービスの仕様変更
- 実装中に設計の欠陥が判明

❌ **使わない場合**：
- 単なるリファクタリング
- 新機能の追加（スコープクリープ）
- 軽微なバグ修正

---

## 制約

- 元の CONFIRMED decision は削除しない（追記のみ）
- 自動でコードを修正しない
- Revision は例外処理（頻発する場合は設計見直し）
- blocked 状態が解除されるまで、実装を進めない

---

## エラー処理

- Feature 不存在 → `check_feature_exists()` がエラー表示
- ブランチ不一致 → `check-branch.sh` がエラー表示
- Decision 未確定 → Decision 確定を促す
- 実装フェーズ外 → エラー表示
- 入力不足 → 再入力を促す
