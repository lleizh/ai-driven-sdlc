# Command: /sdlc-impl-plan

Decision 確定後、実装計画を生成します。

## 使用方法

```
/sdlc-impl-plan <feature-id>
```

## 実行内容

### 1. 前提チェック

Decision Status が CONFIRMED か確認。CONFIRMED でない場合、エラー終了。

### 2. ドキュメント読取

- `.metadata`
- `00_context.md`
- `decisions.md` (CONFIRMED)
- `20_design.md`（存在する場合）
- `risks.md`

### 3. Implementation Plan 生成

テンプレート `sdlc/templates/30_implementation_plan.md` を読取り、以下の内容で埋める：

**実装ステップ**
- Decisions の Chosen Option に基づいて Step 1, Step 2, Step 3... と分割
- 各ステップに何をするかを記載

**高リスクステップ**
- risks.md から High/Medium リスクを確認
- リスクに関連するステップに `⚠️ 高リスク` マーク

**原則**
- Decisions の内容を厳守、勝手に変更しない
- 設計を再議論しない

### 4. ファイル書込

```
sdlc/features/{FEATURE_ID}/30_implementation_plan.md
```

### 5. 完了メッセージ

```
✅ Implementation Plan を生成しました

ファイル: sdlc/features/{FEATURE_ID}/30_implementation_plan.md
```

---

## エラー処理

- Feature 不存在 → `❌ /sdlc-init を先に実行`
- Decision 未確定 → `❌ Design Review で Decisions を確定`
