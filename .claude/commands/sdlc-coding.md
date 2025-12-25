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

### 2. ブランチ切替

Risk Level に応じて分岐：

**低リスク**（すでに `feature/{FEATURE_ID}` にいる場合）：
- そのまま続行（文書とコードを同じブランチで管理）

**中/高リスク**（`design/{FEATURE_ID}` から切り替える場合）：
```bash
# design ブランチの変更を commit（未 commit の場合）
git add .
git commit -m "docs: complete design review"

# develop に切り替えて最新を取得
git checkout develop
git pull origin develop

# develop から feature ブランチを作成
git checkout -b feature/{FEATURE_ID}
```

注：中/高リスクでは、design ドキュメントはすでに develop に merge されている。
feature ブランチは最新の develop（ドキュメント含む）から作成する。

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
```
STATUS=implementing
BRANCH=feature/{FEATURE_ID}
```

### 6. 完了メッセージ

```
✅ 実装が完了しました

ブランチ: feature/{FEATURE_ID}

ファイル変更:
- 新規: {count} ファイル
- 修正: {count} ファイル

テスト結果: PASS/FAIL
ビルド結果: PASS/FAIL

次のステップ: 
1. コード変更を確認
2. /sdlc-pr-code でPR作成
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
