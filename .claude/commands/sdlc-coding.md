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

### 1. 前提チェック

- Decision Status が CONFIRMED か確認
- CONFIRMED でない場合、エラー終了

### 2. ブランチ確認

```bash
# feature ブランチに切り替え
git checkout feature/{FEATURE_ID}

# develop から最新のドキュメントを取得
git pull origin develop --rebase
```

### 3. ドキュメント読取

必須：
- `.metadata`
- `00_context.md`
- `decisions.md` (CONFIRMED)
- `risks.md`

オプション：
- `20_design.md`
- `30_implementation_plan.md`

### 4. 実装

decisions.md の Chosen Options に基づいて実装：
- コード実装（新規ファイル作成、既存ファイル修正）
- テストコード作成
- テスト実行
- ビルド確認

### 5. メタデータ更新

`.metadata` を更新：
```bash
# STATUS を implementing に変更
sed -i '' 's/^STATUS=.*/STATUS=implementing/' sdlc/features/${FEATURE_ID}/.metadata

# LAST_UPDATED を更新
current_date=$(date +%Y-%m-%d)
if grep -q "^LAST_UPDATED=" sdlc/features/${FEATURE_ID}/.metadata; then
  sed -i '' "s/^LAST_UPDATED=.*/LAST_UPDATED=${current_date}/" sdlc/features/${FEATURE_ID}/.metadata
else
  echo "LAST_UPDATED=${current_date}" >> sdlc/features/${FEATURE_ID}/.metadata
fi
```

### 6. Commit と Push

```bash
# .metadata の変更を commit
git add sdlc/features/${FEATURE_ID}/.metadata
git commit -m "chore(${FEATURE_ID}): update STATUS to implementing

Related: #<issue-number>"

git push origin feature/${FEATURE_ID}
```

### 7. 完了メッセージ

```
✅ 実装が完了しました

ブランチ: feature/{FEATURE_ID}

ファイル変更:
- 新規: {count} ファイル
- 修正: {count} ファイル

テスト結果: PASS/FAIL
ビルド結果: PASS/FAIL

次のステップ: 
{Medium/High リスクの場合}
1. /sdlc-test {FEATURE_ID} でテストを実行
2. /sdlc-check {FEATURE_ID} で最終確認
3. /sdlc-pr-code {FEATURE_ID} でPR作成

{Low リスクの場合}
1. /sdlc-check {FEATURE_ID} で最終確認
2. /sdlc-pr-code {FEATURE_ID} でPR作成
```

---

## Design Drift 検出

実装中に Decision と矛盾が発生した場合：
- 実装を停止
- `/sdlc-revise` で Decision を修正するよう促す

---

## 制約

- Decision の内容に厳密に従う
- 既存のコーディング規約に従う（CLAUDE.md）
- 設計を再議論しない

---

## エラー処理

- Feature 不存在 → `❌ /sdlc-init を先に実行`
- Decision 未確定 → `❌ /sdlc-decision で Decision を確定`
- ブランチ切替失敗 → エラー内容を表示
