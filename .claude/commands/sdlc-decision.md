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

### 3. 矛盾チェック（Blocker 判定）

入力された決定内容（Chosen Option, Rationale）と既存ドキュメントとの矛盾をチェック：

**チェック対象**：
- `risks.md` → High/Critical Risk の緩和策と矛盾していないか
- `00_context.md` → Constraints, Non-Goals と矛盾していないか
- `20_design.md`（存在する場合）→ Invariants を破壊していないか

**矛盾の分類**：

#### ❌ Blocker 級矛盾（CONFIRM を阻止、修正必須）

以下の矛盾が見つかった場合、**Status は PENDING のまま、CONFIRM しない**：
- decisions.md に記載された **Non-Negotiables** と矛盾
- `risks.md` の **High/Critical Risk** の緩和策と矛盾
- 新しい **未記録の High/Critical Risk** を導入
- `design.md` の **Invariants**（不変条件）を破壊
- `00_context.md` の **Hard Constraints** に違反

#### ⚠️ Warning 級矛盾（記録するが CONFIRM 可）

以下は警告として記録するが、CONFIRM は許可：
- `risks.md` の Medium Risk 緩和策と軽微に不一致
- `design.md` の推奨パターンから逸脱（強制ではない）
- `00_context.md` の Soft Constraints から逸脱

**矛盾解決フロー**：

1. **Blocker 発見時**：
   - 矛盾の詳細を表示（どの文書のどの箇所と矛盾するか）
   - **Status は PENDING のまま（CONFIRM しない）**
   - Decision Maker に以下の選択肢を提示：
     - **選択肢 A**: Chosen Option を修正し、`/sdlc-decision` を再実行
     - **選択肢 B**: 矛盾するドキュメント（risks.md, context.md など）を更新してから再実行
   - 実行を停止

2. **Warning 発見時**：
   - 矛盾を `decisions.md` の **Known Conflicts** セクションに記録
   - Status を **CONFIRMED** に更新（処理続行）
   - 完了メッセージに警告を表示

### 4. Design ステータス更新

`20_design.md` が存在する場合、ファイル冒頭に追加：
```
Status: FROZEN
```

### 5. 完了メッセージ

**Blocker がない場合（CONFIRMED 成功）**：
```
✅ Decision を CONFIRMED に更新しました

ファイル: sdlc/features/{FEATURE_ID}/decisions.md
Status: CONFIRMED
Decision Maker: {名前}
Date: {日付}

⚠️ Warning: {数}
{Warning がある場合、詳細を表示}

次のステップ:
1. /sdlc-impl-plan {FEATURE_ID} で実装計画を生成
2. /sdlc-coding {FEATURE_ID} で実装を開始
```

**Blocker がある場合（CONFIRMED 失敗）**：
```
❌ Decision を CONFIRMED できませんでした

Status: PENDING のまま

❌ Blocker: {数}
- {Blocker 詳細1: どの文書のどの箇所と矛盾}
- {Blocker 詳細2}

解決方法:
【選択肢 A】Chosen Option を修正
  1. Chosen Option / Rationale を見直し
  2. /sdlc-decision {FEATURE_ID} を再実行

【選択肢 B】矛盾文書を更新
  1. {矛盾する文書} を修正（例: risks.md の緩和策を更新）
  2. /sdlc-decision {FEATURE_ID} を再実行

⚠️ 注意: Blocker を解決せずに実装に進むと、/sdlc-check で再度ブロックされます
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
