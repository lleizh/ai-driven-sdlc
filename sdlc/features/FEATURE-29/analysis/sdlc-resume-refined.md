# /sdlc-resume - Refined Flow Analysis

## コマンド概要
Revision または blocked 状態から実装を再開する

## 使用方法
```bash
/sdlc-resume <feature-id>
```

## 現在の構造
- **ステップ数**: 8
- **共有スクリプト使用**: ❌ 未使用
- **sed 使用**: ⚠️ 大量使用（metadata 更新）
- **複雑度**: 高い（222行、第2長）

---

## 詳細フロー

### Step 1: 前提確認

**目的**: Feature 存在、ブランチ、STATUS の確認

**実行内容**:
```bash
source scripts/common-functions.sh

# Feature 存在確認
check_feature_exists "$FEATURE_ID" || exit 1

# ブランチ確認
scripts/check-branch.sh "$FEATURE_ID" || exit 1

# STATUS 確認（blocked であることを確認）
STATUS=$(get_metadata_value "$FEATURE_ID" "STATUS")

if [[ "$STATUS" != "blocked" ]]; then
    display_error \
        "STATUS が blocked ではありません" \
        "現在: ${STATUS}" \
        "このコマンドは blocked 状態からの再開に使用します"
    exit 1
fi
```

**共有スクリプト**:
- `check_feature_exists()` - Feature 存在確認
- `scripts/check-branch.sh` - ブランチ検証
- `get_metadata_value()` - Metadata 値取得
- `display_error()` - エラー表示

---

### Step 2: 現在の状態を確認

**目的**: Metadata から現在の状態を取得

**実行内容**:
```bash
# 現在の情報を取得
PREVIOUS_STATUS=$(get_metadata_value "$FEATURE_ID" "PREVIOUS_STATUS" || echo "implementing")
DECISION_STATUS=$(get_metadata_value "$FEATURE_ID" "DECISION_STATUS")
REVISION_COUNT=$(get_metadata_value "$FEATURE_ID" "REVISION_COUNT" || echo "0")
BLOCKED_REASON=$(get_metadata_value "$FEATURE_ID" "BLOCKED_REASON")

# 情報を表示
echo "現在の状態:"
echo "  STATUS: blocked"
echo "  PREVIOUS_STATUS: ${PREVIOUS_STATUS}"
echo "  DECISION_STATUS: ${DECISION_STATUS}"
echo "  REVISION_COUNT: ${REVISION_COUNT}"
echo "  BLOCKED_REASON: ${BLOCKED_REASON}"
```

**共有スクリプト**:
- `get_metadata_value()` - Metadata 値取得

---

### Step 3: Implementation Plan 更新の確認

**目的**: Revision がある場合、計画を再生成するか確認

**実行内容**:
```bash
if [[ "$REVISION_COUNT" -gt 0 ]]; then
    LAST_REVISION_REASON=$(get_metadata_value "$FEATURE_ID" "REVISION_${REVISION_COUNT}_REASON")
    
    echo ""
    echo "⚠️ Decision が修訂されています (Revision #${REVISION_COUNT})"
    echo ""
    echo "実装計画を再生成しますか？"
    echo ""
    echo "[Y] はい - 影響が大きい場合、30_implementation_plan.md を再生成"
    echo "[N] いいえ - 影響が小さい場合、既存の計画で続行"
    echo ""
    echo "Revision の内容:"
    echo "  ${LAST_REVISION_REASON}"
    echo ""
    read -p "選択 [Y/N]: " UPDATE_PLAN
fi
```

---

### Step 4: Implementation Plan の更新

**目的**: ユーザーが Y を選択した場合、計画を再生成

**実行内容**:
```bash
if [[ "$UPDATE_PLAN" == "Y" || "$UPDATE_PLAN" == "y" ]]; then
    echo "実装計画を再生成しています..."
    /sdlc-impl-plan "$FEATURE_ID"
fi
```

---

### Step 5: メタデータ更新

**目的**: STATUS を復元し、blocked 関連フィールドを削除

**実行内容**:
```bash
# STATUS を復元
scripts/update-metadata.sh "$FEATURE_ID" "STATUS" "$PREVIOUS_STATUS"

# blocked 関連フィールドを削除
scripts/update-metadata.sh "$FEATURE_ID" "BLOCKED_REASON" ""
scripts/update-metadata.sh "$FEATURE_ID" "BLOCKED_DATE" ""
scripts/update-metadata.sh "$FEATURE_ID" "BLOCKED_BY" ""
scripts/update-metadata.sh "$FEATURE_ID" "PREVIOUS_STATUS" ""

# 再開情報を記録
scripts/update-metadata.sh "$FEATURE_ID" "RESUMED_DATE" "$(date +%Y-%m-%d)"
scripts/update-metadata.sh "$FEATURE_ID" "LAST_UPDATED" "$(date +%Y-%m-%d)"
```

**共有スクリプト**:
- `scripts/update-metadata.sh` - Metadata 更新

**注意**: フィールドを削除する場合は空文字列を設定（`update-metadata.sh` の実装次第）

---

### Step 6: Commit & Push

**目的**: Metadata の変更を commit & push

**実行内容**:
```bash
ISSUE_NUMBER=$(get_metadata_value "$FEATURE_ID" "ISSUE_URL" | grep -oE '[0-9]+$')

git add "sdlc/features/${FEATURE_ID}/.metadata"
git commit -m "chore(${FEATURE_ID}): resume from blocked status

Related: #${ISSUE_NUMBER}"

git push origin "feature/${FEATURE_ID}"
```

**共有スクリプト**:
- `get_metadata_value()` - Metadata 値取得

**完了メッセージ**（出力のみ、ステップではない）:
```
✅ 実装を再開しました

📋 現在の状態:
- Feature ID: ${FEATURE_ID}
- Branch: feature/${FEATURE_ID}
- STATUS: ${PREVIOUS_STATUS} (was: blocked)
- DECISION_STATUS: ${DECISION_STATUS}
- Implementation Plan: ${UPDATE_PLAN == "Y" ? "更新済み" : "既存を使用"}

📝 Revision 情報 (該当する場合):
- Revision Count: ${REVISION_COUNT}
- Last Revision: ${LAST_REVISION_REASON}

📌 次のステップ:
1. 修訂後の Decision を確認:
   sdlc/features/${FEATURE_ID}/decisions.md

2. 必要に応じて既存コードを修正

3. 実装完了後:
   /sdlc-test ${FEATURE_ID}
   /sdlc-check ${FEATURE_ID}
   /sdlc-pr-code ${FEATURE_ID}
```

---

## 最適化提案

### 現在の問題点

1. **共有スクリプト未使用**:
   - `check_feature_exists()` を使うべき
   - `check-branch.sh` を使うべき
   - `get_metadata_value()` を使うべき

2. **sed 大量使用**:
   - Metadata 更新に `sed -i` を多用
   - `update-metadata.sh` を使うべき

3. **Rebase 処理**:
   - Step 5 で rebase を実行
   - 前提確認は「検査」のみ、操作は不要

4. **完了メッセージ**:
   - 独立したステップとしてカウントされている

### 最適化案

**8 Steps → 6 Steps**

```
1. 前提確認（Feature 存在 + ブランチ確認 + STATUS=blocked 確認）
2. 現在の状態を確認（Metadata 読取）
3. Implementation Plan 更新の確認（ユーザー入力）
4. Implementation Plan の更新（Y の場合）
5. メタデータ更新（STATUS 復元、blocked フィールド削除）
6. Commit & Push
```

**変更内容**:
- 前提確認に共有スクリプトを使用
- Metadata 読取に `get_metadata_value()` を使用
- Metadata 更新に `update-metadata.sh` を使用（sed 削除）
- Rebase を削除（前提確認は検査のみ）
- "完了メッセージ" を削除（出力のみ）

---

## エラーハンドリング

| エラー状況 | 処理 | 使用機能 |
|-----------|------|---------|
| Feature 不存在 | エラー表示して終了 | `check_feature_exists()` |
| ブランチ不一致 | エラー表示して終了 | `check-branch.sh` |
| STATUS != blocked | エラー表示して終了 | `get_metadata_value()` |
| PREVIOUS_STATUS 不存在 | implementing に設定 | - |

---

## 共有スクリプト活用状況

❌ **未使用** - 共有スクリプトを使用していない

**追加すべき共有スクリプト**:
- `check_feature_exists()` - Feature 存在確認
- `scripts/check-branch.sh` - ブランチ検証
- `get_metadata_value()` - Metadata 値取得
- `display_error()` - エラー表示
- `scripts/update-metadata.sh` - Metadata 更新

**sed 使用**: ⚠️ 大量使用（すべて `update-metadata.sh` に置き換えるべき）

---

## 使用シーン

### シーン 1: Decision Revision 後
```bash
/sdlc-resume FEATURE-24

# 実装計画の再生成を確認
[Y] はい

# STATUS: blocked → implementing (復元)
✅ 実装を再開しました
```

### シーン 2: 外部依存の阻塞解除後
```bash
/sdlc-resume FEATURE-25

# 実装計画の再生成を確認
[N] いいえ (既存の計画で続行)

# STATUS: blocked → testing (復元)
✅ 実装を再開しました
```

---

## 結論

**現状**: 共有スクリプトを全く使用せず、sed を大量使用

**推奨変更**:
1. 前提確認に共有スクリプトを使用
2. すべての sed を `update-metadata.sh` に置き換え
3. Rebase を削除（前提確認は検査のみ）
4. "完了メッセージ" を削除（出力のみ）

**最終ステップ数**: 8 → **6**

**複雑度**: 高い（条件分岐、計画再生成、複数 metadata フィールド操作）
