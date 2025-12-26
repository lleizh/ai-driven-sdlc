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

### 3. Implementation Plan タスク完成度チェック

`30_implementation_plan.md` が存在する場合、タスク完成度を検証：

```bash
# タスクを抽出
IMPL_PLAN="sdlc/features/${FEATURE_ID}/30_implementation_plan.md"

if [ -f "$IMPL_PLAN" ]; then
  # 全タスク数をカウント
  TOTAL_TASKS=$(grep -E '^\s*-\s+\[[ x]\]' "$IMPL_PLAN" | wc -l | tr -d ' ')
  
  # 完了タスク数をカウント
  COMPLETED_TASKS=$(grep -E '^\s*-\s+\[x\]' "$IMPL_PLAN" | wc -l | tr -d ' ')
  
  # 未完了タスク数をカウント
  INCOMPLETE_TASKS=$(grep -E '^\s*-\s+\[ \]' "$IMPL_PLAN" | wc -l | tr -d ' ')
  
  # カテゴリ別に未完了タスクを分類（キーワードベース）
  DOC_INCOMPLETE=$(grep -E '^\s*-\s+\[ \]' "$IMPL_PLAN" | grep -iE '(README|document|doc\s|guide|説明|ドキュメント)' | wc -l | tr -d ' ')
  TEST_INCOMPLETE=$(grep -E '^\s*-\s+\[ \]' "$IMPL_PLAN" | grep -iE '(test|テスト|検証)' | wc -l | tr -d ' ')
  CORE_INCOMPLETE=$((INCOMPLETE_TASKS - DOC_INCOMPLETE - TEST_INCOMPLETE))
  
  # 完成率を計算
  if [ "$TOTAL_TASKS" -gt 0 ]; then
    COMPLETION_RATE=$((COMPLETED_TASKS * 100 / TOTAL_TASKS))
  else
    COMPLETION_RATE=0
  fi
fi
```

**チェック基準**:
- Documentation タスク未完了 → 警告
- Testing タスク未完了 → 警告（High Risk の場合はブロッカー）
- Core 実装タスク未完了 → ブロッカー

### 4. 一致性チェック

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

### 5. 結果を表示

**ターミナルに直接表示**（ファイルには書き込まない）：

```
=================================================
  Pre-PR Check: {FEATURE_ID}
  Date: {日付}
=================================================

📊 Implementation Plan タスク完成度
  - 全タスク: {TOTAL_TASKS}
  - 完了: {COMPLETED_TASKS} ({COMPLETION_RATE}%)
  - 未完了: {INCOMPLETE_TASKS}
    - Documentation: {DOC_INCOMPLETE}
    - Testing: {TEST_INCOMPLETE}
    - Core実装: {CORE_INCOMPLETE}

✅ 問題なし
  - {チェック項目}

⚠️  警告 ({数})
  - {警告内容}
    推奨: {対応方法}
  {Documentation タスクが未完了の場合}
  - Documentation タスクが {DOC_INCOMPLETE} 件未完了
    推奨: README、ガイド、ドキュメントを完成させる
  {Testing タスクが未完了の場合 (Low/Medium Risk)}
  - Testing タスクが {TEST_INCOMPLETE} 件未完了
    推奨: テストを実装して実行する

❌ ブロッカー ({数})
  - {重大な問題}
    必須: {修正が必要}
  {Core実装タスクが未完了の場合}
  - Core実装タスクが {CORE_INCOMPLETE} 件未完了
    必須: 全てのCore実装タスクを完了させる
  {Testing タスクが未完了の場合 (High Risk)}
  - Testing タスクが {TEST_INCOMPLETE} 件未完了（High Risk）
    必須: 全てのTestingタスクを完了させる

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
