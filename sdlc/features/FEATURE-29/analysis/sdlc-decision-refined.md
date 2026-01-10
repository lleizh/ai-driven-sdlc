# /sdlc-decision - Refined Flow Analysis

## コマンド概要
Decision Maker が最終決定を確定し、decisions.md に記録します

## 使用方法
```bash
/sdlc-decision <feature-id>
```

**入力情報**:
- Decision Topic
- Chosen Option
- Rejected Options
- Rationale
- Accepted Risks
- Non-Negotiables
- Decision Maker（名前）

## 現在の構造
- **ステップ数**: 7
- **共有スクリプト使用**: ⚠️ 部分的（`check_feature_exists` のみ）
- **sed 使用**: ⚠️ あり（metadata 更新）

---

## 詳細フロー

### Step 1: 前提確認

**目的**: Feature 存在、ブランチ、decisions.md の確認

**実行内容**:
```bash
source scripts/common-functions.sh

# Feature 存在確認
check_feature_exists "$FEATURE_ID" || exit 1

# ブランチ確認
scripts/check-branch.sh "$FEATURE_ID" || exit 1

# decisions.md 存在確認
DECISIONS_FILE="sdlc/features/${FEATURE_ID}/decisions.md"
if [[ ! -f "$DECISIONS_FILE" ]]; then
    display_error \
        "decisions.md が見つかりません" \
        "/sdlc-init ${FEATURE_ID} を先に実行してください"
    exit 1
fi

# 既に CONFIRMED でないか確認
DECISION_STATUS=$(get_metadata_value "$FEATURE_ID" "DECISION_STATUS")
if [[ "$DECISION_STATUS" == "confirmed" ]]; then
    echo "⚠️ 既に CONFIRMED です"
    echo "修正が必要な場合は /sdlc-revise を使用してください"
    exit 0
fi
```

**共有スクリプト**:
- `check_feature_exists()` - Feature 存在確認
- `scripts/check-branch.sh` - ブランチ検証
- `get_metadata_value()` - Metadata 値取得
- `display_error()` - エラー表示

---

### Step 2: ドキュメント読取

**目的**: 矛盾チェックに必要な情報を収集

**読取ドキュメント**:
```bash
FEATURE_DIR="sdlc/features/${FEATURE_ID}"

# 必須
- ${FEATURE_DIR}/decisions.md
- ${FEATURE_DIR}/00_context.md
- ${FEATURE_DIR}/risks.md

# オプション
- ${FEATURE_DIR}/20_design.md
```

---

### Step 3: ユーザー入力を収集

**目的**: Decision 内容を取得

**収集する情報**:
```bash
read -p "Decision Topic: " TOPIC
read -p "Chosen Option: " CHOSEN
read -p "Rejected Options (カンマ区切り): " REJECTED
read -p "Rationale: " RATIONALE
read -p "Accepted Risks (カンマ区切り): " ACCEPTED_RISKS
read -p "Non-Negotiables (カンマ区切り): " NON_NEGOTIABLES
read -p "Decision Maker (名前): " MAKER
```

---

### Step 4: 矛盾チェック

**目的**: 入力内容と既存ドキュメントの矛盾を検出

**チェック項目**:

#### ❌ Blocker 級（CONFIRM 阻止）:
- Non-Negotiables との矛盾
- risks.md の High/Critical Risk 緩和策と矛盾
- 新しい未記録 High/Critical Risk を導入
- design.md の Invariants を破壊
- context.md の Hard Constraints 違反

#### ⚠️ Warning 級（記録するが CONFIRM 可）:
- risks.md の Medium Risk と軽微な不一致
- design.md の推奨パターンから逸脱
- context.md の Soft Constraints から逸脱

**実行内容**:
```bash
BLOCKERS=()
WARNINGS=()

# AI が各ドキュメントを分析
# - Chosen Option と RATIONALE を検証
# - 矛盾を BLOCKERS または WARNINGS に分類

if [[ ${#BLOCKERS[@]} -gt 0 ]]; then
    echo "❌ Blocker: ${#BLOCKERS[@]}"
    for blocker in "${BLOCKERS[@]}"; do
        echo "  - $blocker"
    done
    
    echo ""
    echo "解決方法:"
    echo "【選択肢 A】Chosen Option を修正して再実行"
    echo "【選択肢 B】矛盾文書を更新して再実行"
    exit 1
fi
```

---

### Step 5: decisions.md を更新

**目的**: Decision を CONFIRMED として記録

**実行内容**:
```bash
# decisions.md を更新
# - Status: PENDING → CONFIRMED
# - Decision Topic, Chosen Option, Rejected Options, etc. を記入
# - Date: $(date +%Y-%m-%d)
# - Decision Maker: $MAKER

# Warning がある場合、Known Conflicts セクションに追加
if [[ ${#WARNINGS[@]} -gt 0 ]]; then
    # Add Known Conflicts section
fi

# Write ツールで更新
```

---

### Step 6: design.md を更新

**目的**: Design を FROZEN にする

**実行内容**:
```bash
DESIGN_FILE="sdlc/features/${FEATURE_ID}/20_design.md"

if [[ -f "$DESIGN_FILE" ]]; then
    # Status: APPROVED → FROZEN
    # Edit ツールで置換
fi
```

---

### Step 7: メタデータ更新

**目的**: DECISION_STATUS を confirmed に更新

**実行内容**:
```bash
scripts/update-metadata.sh "$FEATURE_ID" "DECISION_STATUS" "confirmed"
scripts/update-metadata.sh "$FEATURE_ID" "LAST_UPDATED" "$(date +%Y-%m-%d)"
```

**共有スクリプト**:
- `scripts/update-metadata.sh` - Metadata 更新

---

### Step 8: Commit & Push

**目的**: すべての変更を commit & push

**実行内容**:
```bash
ISSUE_NUMBER=$(get_metadata_value "$FEATURE_ID" "ISSUE_URL" | grep -oE '[0-9]+$')

git add "sdlc/features/${FEATURE_ID}/decisions.md"
git add "sdlc/features/${FEATURE_ID}/.metadata"

if [[ -f "sdlc/features/${FEATURE_ID}/20_design.md" ]]; then
    git add "sdlc/features/${FEATURE_ID}/20_design.md"
fi

git commit -m "docs(${FEATURE_ID}): confirm decisions

Decision Maker: ${MAKER}

Related: #${ISSUE_NUMBER}"

git push origin "feature/${FEATURE_ID}"
```

**共有スクリプト**:
- `get_metadata_value()` - Metadata 値取得

**完了メッセージ**（出力のみ、ステップではない）:

**成功時**:
```
✅ Decision を CONFIRMED に更新しました

Status: CONFIRMED
Decision Maker: ${MAKER}

⚠️ Warning: ${#WARNINGS[@]}
${WARNINGS[@]}

次のステップ:
1. /sdlc-impl-plan ${FEATURE_ID}
2. /sdlc-coding ${FEATURE_ID}
```

**失敗時**（Blocker あり）:
```
❌ Decision を CONFIRMED できませんでした

Status: PENDING

❌ Blocker: ${#BLOCKERS[@]}
${BLOCKERS[@]}

解決方法:
【選択肢 A】Chosen Option を修正して再実行
【選択肢 B】矛盾文書を更新して再実行
```

---

## 最適化提案

### 現在の問題点

1. **共有スクリプト不足**:
   - `check_feature_exists()` のみ使用
   - `check-branch.sh`, `get_metadata_value()`, `display_error()` を使うべき

2. **sed 使用**:
   - Metadata 更新に `sed -i` を使用
   - `update-metadata.sh` を使うべき

3. **完了メッセージ**:
   - 独立したステップとしてカウントされている

### 最適化案

**7 Steps → 8 Steps**

```
1. 前提確認（Feature 存在 + ブランチ確認 + decisions.md 確認）
2. ドキュメント読取（decisions, context, risks, design）
3. ユーザー入力を収集（Topic, Chosen, Rejected, etc.）
4. 矛盾チェック（Blocker 判定）
5. decisions.md を更新（Status: CONFIRMED）
6. design.md を更新（Status: FROZEN）
7. メタデータ更新（DECISION_STATUS=confirmed）
8. Commit & Push
```

**変更内容**:
- 前提確認に共有スクリプトを追加
- Metadata 更新に `update-metadata.sh` を使用（sed 削除）
- ユーザー入力を独立ステップに
- "完了メッセージ" を削除（出力のみ）

---

## エラーハンドリング

| エラー状況 | 処理 | 使用機能 |
|-----------|------|---------|
| Feature 不存在 | エラー表示して終了 | `check_feature_exists()` |
| ブランチ不一致 | エラー表示して終了 | `check-branch.sh` |
| decisions.md 不存在 | エラー表示 | - |
| 既に CONFIRMED | 警告表示 | `get_metadata_value()` |
| Blocker 検出 | CONFIRM せず終了 | - |

---

## 共有スクリプト活用状況

⚠️ **部分的** - `check_feature_exists()` のみ使用

**追加すべき共有スクリプト**:
- `scripts/check-branch.sh` - ブランチ検証
- `get_metadata_value()` - Metadata 値取得
- `display_error()` - エラー表示
- `scripts/update-metadata.sh` - Metadata 更新

**sed 使用**: ⚠️ あり（`update-metadata.sh` に置き換えるべき）

---

## 結論

**現状**: 一部の共有スクリプトのみ使用、sed で metadata 更新

**推奨変更**:
1. 前提確認に共有スクリプトを追加
2. sed を `update-metadata.sh` に置き換え
3. ユーザー入力を独立ステップに
4. "完了メッセージ" を削除（出力のみ）

**最終ステップ数**: 7 → **8**

**特殊性**: 唯一の矛盾チェック機能（Blocker/Warning 判定）
