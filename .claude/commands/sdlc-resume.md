---
description: Revision または blocked 状態から実装を再開する
---

# Command: /sdlc-resume

Decision Revision 完了後、または blocked 状態解除後に実装を再開します。

## 使用方法

```
/sdlc-resume <feature-id>
```

## 実行内容

### 1. 前提確認

**共有スクリプトを使用**：
```bash
source scripts/common-functions.sh

# Feature 存在確認
check_feature_exists "$FEATURE_ID" || exit 1

# ブランチ検証
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

### 2. 現在の状態を確認

`.metadata` から現在の状態を取得：

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

### 3. Implementation Plan 更新の確認

Revision がある場合、ユーザーに確認：

```
⚠️ Decision が修訂されています (Revision #${REVISION_COUNT})

実装計画を再生成しますか？

[Y] はい - 影響が大きい場合、30_implementation_plan.md を再生成
[N] いいえ - 影響が小さい場合、既存の計画で続行

Revision の内容:
  ${LAST_REVISION_REASON}

選択 [Y/N]:
```

### 4. Implementation Plan の更新

ユーザーが Y を選択した場合：

```bash
if [[ "$UPDATE_PLAN" == "Y" || "$UPDATE_PLAN" == "y" ]]; then
    echo "実装計画を再生成しています..."
    /sdlc-impl-plan "$FEATURE_ID"
fi
```

### 5. メタデータ更新

**共有スクリプトを使用**：
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

### 6. Commit & Push

```bash
ISSUE_NUMBER=$(get_metadata_value "$FEATURE_ID" "ISSUE_URL" | grep -oE '[0-9]+$')

git add "sdlc/features/${FEATURE_ID}/.metadata"
git commit -m "chore(${FEATURE_ID}): resume from blocked status

Related: #${ISSUE_NUMBER}"

git push origin "feature/${FEATURE_ID}"
```

---

## 完了後の次のステップ

実装を再開した後：

1. 修訂後の Decision を確認:
   - `sdlc/features/{FEATURE_ID}/decisions.md`

2. 必要に応じて既存コードを修正

3. 実装完了後:
   - `/sdlc-test {FEATURE_ID}`
   - `/sdlc-check {FEATURE_ID}`
   - `/sdlc-pr-code {FEATURE_ID}`

---

## 共有スクリプトの活用

このコマンドは以下の共有機能を使用：
- `check_feature_exists()` - Feature 存在確認
- `check-branch.sh` - ブランチ検証
- `get_metadata_value()` - Metadata 値取得
- `display_error()` - エラー表示
- `update-metadata.sh` - Metadata 更新

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

## 制約

- 自動でコードを修正しない
- ユーザーが手動で修訂後の Decision に基づいてコードを調整する必要がある
- Revision が複数回ある場合、最新の Revision のみを表示

---

## エラー処理

- Feature 不存在 → `check_feature_exists()` がエラー表示
- ブランチ不一致 → `check-branch.sh` がエラー表示
- STATUS != blocked → エラー表示
- PREVIOUS_STATUS 不存在 → implementing に設定

---

## 関連コマンド

- `/sdlc-revise` - Decision を修訂し blocked 状態にする
- `/sdlc-impl-plan` - 実装計画を生成/更新
- `/sdlc-check` - 実装と Decision の一致性を確認
