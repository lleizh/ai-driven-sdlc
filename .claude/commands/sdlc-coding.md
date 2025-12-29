---
description: Decision 確定後、実装を開始する
---

# Command: /sdlc-coding

Decision 確定後、AI が実装を実行します。

## 使用方法

```
/sdlc-coding <feature-id>
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

# Decision Status 確認
DECISION_STATUS=$(get_metadata_value "$FEATURE_ID" "DECISION_STATUS")

if [[ "$DECISION_STATUS" != "confirmed" ]]; then
    display_error \
        "Decision が CONFIRMED ではありません" \
        "現在: ${DECISION_STATUS}" \
        "/sdlc-decision ${FEATURE_ID} で Decision を確定してください"
    exit 1
fi
```

### 2. ドキュメント読取

必須：
- `.metadata`
- `00_context.md`
- `decisions.md` (CONFIRMED)
- `risks.md`

オプション：
- `20_design.md`
- `30_implementation_plan.md`

### 3. 実装

decisions.md の Chosen Options に基づいて実装：
- コード実装（新規ファイル作成、既存ファイル修正）
- テストコード作成
- テスト実行
- ビルド確認

**実装の原則**：
- Chosen Options に厳密に従う
- Rejected Options は使用しない
- Non-Negotiables を守る

**Design Drift 検出**：
実装中に Decision と矛盾が発生した場合、実装を停止し `/sdlc-revise` で Decision を修正するよう促す

### 4. メタデータ更新

**共有スクリプトを使用**：
```bash
scripts/update-metadata.sh "$FEATURE_ID" "STATUS" "implementing"
scripts/update-metadata.sh "$FEATURE_ID" "LAST_UPDATED" "$(date +%Y-%m-%d)"
```

---

## 完了後の次のステップ

実装完了後、Risk Level に応じて：

**Medium/High Risk**:
1. `/sdlc-test {FEATURE_ID}` でテストを実行
2. `/sdlc-check {FEATURE_ID}` で最終確認
3. `/sdlc-pr-code {FEATURE_ID}` でPR作成

**Low Risk**:
1. `/sdlc-check {FEATURE_ID}` で最終確認
2. `/sdlc-pr-code {FEATURE_ID}` でPR作成

---

## 共有スクリプトの活用

このコマンドは以下の共有機能を使用：
- `check_feature_exists()` - Feature 存在確認
- `get_metadata_value()` - Metadata 値取得
- `display_error()` - エラー表示
- `check-branch.sh` - ブランチ検証
- `update-metadata.sh` - Metadata 更新

---

## 制約

- Decision の内容に厳密に従う
- 既存のコーディング規約に従う（CLAUDE.md）
- 設計を再議論しない
- コード変更は開発者自身が commit/push する

---

## エラー処理

- Feature 不存在 → `check_feature_exists()` がエラー表示
- Decision 未確定 → `display_error()` でガイダンス表示
- ブランチ不一致 → `check-branch.sh` がエラー表示
