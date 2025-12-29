# Command: /sdlc-impl-plan

Decision 確定後、実装計画を生成します。

## 使用方法

```
/sdlc-impl-plan <feature-id>
```

## 実行内容

### 1. 前提チェック

**共有スクリプトを使用**：
```bash
source scripts/common-functions.sh

# Feature 存在確認
check_feature_exists "$FEATURE_ID" || exit 1

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

以下のファイルを Read ツールで読み取る：

**必須**：
- `.metadata` - Feature ID、Risk Level、Status
- `00_context.md` - Goals、Constraints、Success Metrics
- `decisions.md` - CONFIRMED 済みの Chosen Options
- `risks.md` - High/Medium Risk

**オプション**：
- `20_design.md` - Architecture、Component Design（存在する場合）

### 3. Implementation Plan 生成

テンプレート `sdlc/templates/30_implementation_plan.md` を読取り、以下の内容で埋める：

**実装 Phases**：
- Decisions の Chosen Options に基づいて Phase 1, 2, 3... と分割
- 各 Phase にタスクリストを記載（チェックボックス形式）
- タスクの粒度：1タスク = 1-2時間で完了

**高リスクタスク**：
- risks.md から High/Medium Risk を確認
- リスク関連タスクに `⚠️ 高リスク` マークと緩和策を記載

**Testing Strategy**：
- Unit Tests、Integration Tests、E2E Tests の計画
- テストカバレッジ目標

**Timeline**：
- 各 Phase の推定工数
- 総タスク数と総時間

**重要な原則**：
- Decisions の内容を厳守、勝手に変更しない
- 設計を再議論しない
- 具体的なファイル名・関数名を記載

### 4. ファイル書込

Write ツールで生成した内容を書き込む：
```
sdlc/features/{FEATURE_ID}/30_implementation_plan.md
```

### 5. メタデータ更新

**共有スクリプトを使用**：
```bash
scripts/update-metadata.sh "$FEATURE_ID" "LAST_UPDATED" "$(date +%Y-%m-%d)"
```

### 6. Commit と Push

```bash
ISSUE_URL=$(get_metadata_value "$FEATURE_ID" "ISSUE_URL")
ISSUE_NUMBER=$(echo "$ISSUE_URL" | grep -oE '[0-9]+$')

git add "sdlc/features/${FEATURE_ID}/30_implementation_plan.md"
git add "sdlc/features/${FEATURE_ID}/.metadata"

git commit -m "docs(${FEATURE_ID}): generate implementation plan

Based on confirmed decisions

Related: #${ISSUE_NUMBER}"

git push origin "feature/${FEATURE_ID}"
```

### 7. 完了メッセージ

```
✅ Implementation Plan を生成しました

📋 計画情報:
- ファイル: sdlc/features/{FEATURE_ID}/30_implementation_plan.md
- Phases: {Phase数}
- Tasks: {タスク数}

次のステップ:
1. Implementation Plan を確認
2. /sdlc-coding {FEATURE_ID} で実装を開始
```

---

## 共有スクリプトの活用

このコマンドは以下の共有機能を使用：
- `check_feature_exists()` - Feature 存在確認
- `get_metadata_value()` - Metadata 値取得
- `display_error()` - エラー表示
- `update-metadata.sh` - Metadata 更新

詳細は `scripts/common-functions.sh` を参照。

---

## エラー処理

- Feature 不存在 → `check_feature_exists()` がエラー表示
- Decision 未確定 → `display_error()` でガイダンス表示
- テンプレート不存在 → エラー表示して終了
