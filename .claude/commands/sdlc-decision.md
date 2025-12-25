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

### 1. ドキュメント読取

- `sdlc/features/{FEATURE_ID}/decisions.md`
- `sdlc/features/{FEATURE_ID}/20_design.md`（存在する場合）

### 2. 入力された決定内容を記録

`decisions.md` を更新：
- Status: PENDING → **CONFIRMED**
- Chosen Option を記入
- Rejected Options を記入
- Rationale を記入
- Accepted Risks を記入
- Non-Negotiables を記入
- Decision Maker を記入
- Date: 今日の日付

### 3. 冲突チェック

入力された決定内容が既存ドキュメントと矛盾する場合：
- 矛盾リストを表示
- **勝手に修正しない**
- Decision Maker に確認を求める

### 4. Design ステータス更新

`20_design.md` が存在する場合、ファイル冒頭に追加：
```
Status: FROZEN
```

### 5. 完了メッセージ

```
✅ Decision を CONFIRMED に更新しました

ファイル: sdlc/features/{FEATURE_ID}/decisions.md
Status: CONFIRMED
Decision Maker: {名前}
Date: {日付}

⚠️ 矛盾（ある場合）:
- {矛盾1}
- {矛盾2}
```

---

## 制約

- 新しい要件や設計を追加しない
- 既存ドキュメントを勝手に修正しない
- 矛盾がある場合は報告のみ

---

## エラー処理

- Feature 不存在 → `❌ /sdlc-init を先に実行`
- decisions.md が既に CONFIRMED → `⚠️ 既に CONFIRMED です`
