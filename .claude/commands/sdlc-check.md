# Command: /sdlc-check

PR 作成前に実装の一致性をチェックします。

## 使用方法

```
/sdlc-check <feature-id>
```

## 実行内容

### 1. ドキュメント読取

- `sdlc/features/{FEATURE_ID}/decisions.md` (CONFIRMED)
- `sdlc/features/{FEATURE_ID}/risks.md`
- `sdlc/features/{FEATURE_ID}/20_design.md`（存在する場合）
- `sdlc/features/{FEATURE_ID}/30_implementation_plan.md`（存在する場合）

### 2. コード変更を確認

現在の git diff を確認：
```bash
git diff main...HEAD
```

### 3. 一致性チェック

以下をチェック：

**Decisions との一致**
- 実装が Chosen Option に従っているか
- Rejected Options を使っていないか
- Non-Negotiables が守られているか

**リスク管理**
- risks.md に記録されていない新しいリスクがないか
- 高リスクステップの緩和策が実装されているか

**設計との一致**
- design.md の方針から逸脱していないか
- Invariants（不変条件）が破壊されていないか

### 4. 結果を表示

**ターミナルに直接表示**（ファイルには書き込まない）：

```
=================================================
  Pre-PR Check: {FEATURE_ID}
  Date: {日付}
=================================================

✅ 問題なし
  - {チェック項目}

⚠️  警告 ({数})
  - {警告内容}
    推奨: {対応方法}

❌ ブロッカー ({数})
  - {重大な問題}
    必須: {修正が必要}

=================================================
Summary: {ブロッカー数} blockers, {警告数} warnings

{ブロッカーがある場合}
❌ PR 作成前に修正が必要です

{ブロッカーがない場合}
✅ PR 作成可能です
=================================================
```

**注意**: 
- Self-Check の結果は repository に commit しない
- 問題があれば修正後に再度 `/sdlc-check` を実行
- Peer Review の結果は `/sdlc-pr-design` と `/sdlc-pr-impl` で `40_review_findings.md` に記録される

---

## チェック基準

**ブロッカー**（修正必須）:
- decisions.md から明確に逸脱
- 新しい未記録リスクがある
- Non-Negotiables が破られている

**警告**（推奨修正）:
- Implementation Plan から若干ずれている
- リスク緩和策が不完全
- テストカバレッジ不足

**問題なし**:
- Decisions に完全に従っている
- リスクが適切に管理されている
- 設計方針を守っている

---

## エラー処理

- Feature 不存在 → `❌ /sdlc-init を先に実行`
- Decision 未確定 → `❌ Decision を CONFIRMED にしてください`
- git diff が空 → `⚠️ 変更がありません`
