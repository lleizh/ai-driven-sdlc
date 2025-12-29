---
description: Decision Maker が最終決定を確定し、decisions.md に記録する
---

# Command: /sdlc-decision

Decision Maker が最終決定を確定し、decisions.md に記録します。

## 使用方法

```
/sdlc-decision <feature-id>
```

実行時、以下の情報を入力してください：
- Decision Topic
- Chosen Option
- Rejected Options
- Rationale
- Accepted Risks
- Non-Negotiables
- Decision Maker（あなたの名前/アカウント）

## 実行内容

### 1. 前提確認

**共有スクリプトを使用**：
```bash
source scripts/common-functions.sh

# Feature 存在確認
check_feature_exists "$FEATURE_ID" || exit 1

# ブランチ検証
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

### 2. ドキュメント読取

以下のドキュメントを読み取る：
- `decisions.md`
- `00_context.md`
- `risks.md`
- `20_design.md`（存在する場合）

### 3. ユーザー入力を収集

以下の情報を収集：
```bash
read -p "Decision Topic: " TOPIC
read -p "Chosen Option: " CHOSEN
read -p "Rejected Options (カンマ区切り): " REJECTED
read -p "Rationale: " RATIONALE
read -p "Accepted Risks (カンマ区切り): " ACCEPTED_RISKS
read -p "Non-Negotiables (カンマ区切り): " NON_NEGOTIABLES
read -p "Decision Maker (名前): " MAKER
```

### 4. 矛盾チェック

入力された決定内容と既存ドキュメントとの矛盾をチェック：

**チェック対象**：
- `risks.md` → High/Critical Risk の緩和策と矛盾していないか
- `00_context.md` → Constraints, Non-Goals と矛盾していないか
- `20_design.md` → Invariants を破壊していないか

**矛盾の分類**：

#### Blocker 級矛盾（CONFIRM を阻止）

以下の矛盾が見つかった場合、Status は PENDING のまま、CONFIRM しない：
- Non-Negotiables と矛盾
- `risks.md` の High/Critical Risk の緩和策と矛盾
- 新しい未記録の High/Critical Risk を導入
- `design.md` の Invariants を破壊
- `00_context.md` の Hard Constraints に違反

#### Warning 級矛盾（記録するが CONFIRM 可）

以下は警告として記録するが、CONFIRM は許可：
- `risks.md` の Medium Risk 緩和策と軽微に不一致
- `design.md` の推奨パターンから逸脱
- `00_context.md` の Soft Constraints から逸脱

**Blocker 発見時**：
- 矛盾の詳細を表示
- Status は PENDING のまま
- 実行を停止
- Decision Maker に選択肢を提示：
  - 選択肢 A: Chosen Option を修正して再実行
  - 選択肢 B: 矛盾するドキュメントを更新して再実行

**Warning 発見時**：
- 矛盾を `decisions.md` の Known Conflicts セクションに記録
- Status を CONFIRMED に更新（処理続行）
- 完了メッセージに警告を表示

### 5. decisions.md を更新

`decisions.md` を更新：
- Status: PENDING → CONFIRMED
- Decision Topic, Chosen Option, Rejected Options, etc. を記入
- Date: $(date +%Y-%m-%d)
- Decision Maker: $MAKER

Warning がある場合、Known Conflicts セクションに追加

### 6. design.md を更新

`20_design.md` が存在する場合：
```markdown
Status: APPROVED → FROZEN
```

### 7. メタデータ更新

**共有スクリプトを使用**：
```bash
scripts/update-metadata.sh "$FEATURE_ID" "DECISION_STATUS" "confirmed"
scripts/update-metadata.sh "$FEATURE_ID" "LAST_UPDATED" "$(date +%Y-%m-%d)"
```

### 8. Commit & Push

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

---

## 完了後の次のステップ

**Blocker がない場合（CONFIRMED 成功）**：
1. `/sdlc-impl-plan {FEATURE_ID}` で実装計画を生成
2. `/sdlc-coding {FEATURE_ID}` で実装を開始

**Blocker がある場合（CONFIRMED 失敗）**：
- 選択肢 A: Chosen Option を修正して再実行
- 選択肢 B: 矛盾するドキュメントを更新して再実行

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
- 唯一の矛盾チェック機能（Blocker/Warning 判定）
- Blocker がある場合は CONFIRM しない
- Warning は記録するが CONFIRM 可能

---

## 制約

- 新しい要件や設計を追加しない
- 既存ドキュメントを勝手に修正しない
- 矛盾がある場合は報告のみ
- Blocker を解決せずに実装に進むと、/sdlc-check で再度ブロックされる

---

## エラー処理

- Feature 不存在 → `check_feature_exists()` がエラー表示
- ブランチ不一致 → `check-branch.sh` がエラー表示
- decisions.md 不存在 → エラー表示
- 既に CONFIRMED → 警告表示、/sdlc-revise を促す
- Blocker 検出 → CONFIRM せず終了
