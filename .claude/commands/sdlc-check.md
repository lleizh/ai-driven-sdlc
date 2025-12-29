---
description: PR 作成前に実装の一致性をチェックする
---

# Command: /sdlc-check

PR 作成前に実装の一致性をチェックします。

## 使用方法

```
/sdlc-check <feature-id>
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
```

### 2. ドキュメント & コード読取

**ドキュメント読取**：
- `.metadata`
- `decisions.md` (CONFIRMED)
- `risks.md`
- `20_design.md`（存在する場合）
- `30_implementation_plan.md`（存在する場合）

**コード変更を確認**：
```bash
# 現在の git diff を取得
CODE_CHANGES=$(git diff main...HEAD)

# 変更がない場合は警告
if [[ -z "$CODE_CHANGES" ]]; then
    log_warning "コード変更がありません"
fi
```

### 3. タスク完成度 & 一致性チェック

#### 3.1 Implementation Plan タスク完成度チェック

`30_implementation_plan.md` が存在する場合、タスク完成度を検証：

```bash
IMPL_PLAN="sdlc/features/${FEATURE_ID}/30_implementation_plan.md"

if [[ -f "$IMPL_PLAN" ]]; then
    # 全タスク数をカウント
    TOTAL_TASKS=$(grep -E '^\s*-\s+\[[ x]\]' "$IMPL_PLAN" | wc -l | tr -d ' ')
    
    # 完了タスク数をカウント
    COMPLETED_TASKS=$(grep -E '^\s*-\s+\[x\]' "$IMPL_PLAN" | wc -l | tr -d ' ')
    
    # 未完了タスク数をカウント
    INCOMPLETE_TASKS=$(grep -E '^\s*-\s+\[ \]' "$IMPL_PLAN" | wc -l | tr -d ' ')
    
    # カテゴリ別に未完了タスクを分類
    DOC_INCOMPLETE=$(grep -E '^\s*-\s+\[ \]' "$IMPL_PLAN" | grep -iE '(README|document|doc\s|guide|説明|ドキュメント)' | wc -l | tr -d ' ')
    TEST_INCOMPLETE=$(grep -E '^\s*-\s+\[ \]' "$IMPL_PLAN" | grep -iE '(test|テスト|検証)' | wc -l | tr -d ' ')
    CORE_INCOMPLETE=$((INCOMPLETE_TASKS - DOC_INCOMPLETE - TEST_INCOMPLETE))
    
    # 完成率を計算
    if [[ "$TOTAL_TASKS" -gt 0 ]]; then
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

#### 3.2 一致性チェック

**Decisions との一致**：
- 実装が Chosen Option に従っているか
- Rejected Options を使っていないか
- Non-Negotiables が守られているか

**リスク管理**：
- risks.md に記録されていない新しいリスクがないか
- 高リスクステップの緩和策が実装されているか

**設計との一致**：
- design.md の方針から逸脱していないか
- Invariants（不変条件）が破壊されていないか

**判定基準**：

| 重大度 | 条件 | 対応 |
|-------|------|-----|
| ブロッカー | Core実装タスク未完了<br>Testing タスク未完了（High Risk）<br>decisions.md から逸脱<br>Non-Negotiables 違反<br>新しい未記録リスク | 修正必須 |
| 警告 | Documentation タスク未完了<br>Testing タスク未完了（Low/Medium Risk）<br>Implementation Plan からずれ<br>リスク緩和策が不完全 | 推奨修正 |
| 問題なし | 全タスク完了<br>Decisions に従っている<br>リスク適切管理 | PR 可能 |

### 4. 結果分析 & 表示

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

---

## 完了後の次のステップ

**ブロッカーなし**：
1. `/sdlc-pr-code {FEATURE_ID}` - Code Review PR 作成

**ブロッカーあり**：
1. 問題を修正
2. `/sdlc-check {FEATURE_ID}` - 再チェック

---

## 共有スクリプトの活用

このコマンドは以下の共有機能を使用：
- `check_feature_exists()` - Feature 存在確認
- `check-branch.sh` - ブランチ検証
- `get_metadata_value()` - Metadata 値取得
- `log_info()`, `log_warning()` - ログ出力

---

## 特徴

**このコマンドの特殊性**：
- 唯一、結果をファイルに書き込まない（ターミナル表示のみ）
- 唯一、metadata を更新しない
- Self-Check のため、記録を残さない
- 何度でも実行可能

**Peer Review との違い**：
- Self-Check: `/sdlc-check` → 記録しない
- Peer Review: `/sdlc-pr-design`, `/sdlc-pr-code` → `40_review_findings.md` に記録

---

## エラー処理

- Feature 不存在 → `check_feature_exists()` がエラー表示
- ブランチ不一致 → `check-branch.sh` がエラー表示
- Decision 未確定 → 警告表示
- git diff が空 → 警告表示
- ブロッカーあり → PR 作成不可を表示
