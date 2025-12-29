# /sdlc-check - Refined Flow Analysis

## コマンド概要
PR 作成前に実装の一致性をチェックします

## 使用方法
```bash
/sdlc-check <feature-id>
```

## 現在の構造
- **ステップ数**: 5
- **共有スクリプト使用**: ❌ 未使用
- **前提確認**: ❌ 欠落
- **ブランチ確認**: ❌ 欠落

---

## 詳細フロー

### Step 1: 前提確認

**目的**: Feature 存在とブランチの確認

**実行内容**:
```bash
source scripts/common-functions.sh

# Feature 存在確認
check_feature_exists "$FEATURE_ID" || exit 1

# ブランチ確認
scripts/check-branch.sh "$FEATURE_ID" || exit 1
```

**共有スクリプト**:
- `check_feature_exists()` - Feature 存在確認
- `scripts/check-branch.sh` - ブランチ検証

---

### Step 2: ドキュメント & コード読取

**目的**: チェックに必要な情報を収集

**読取ドキュメント**:
```bash
FEATURE_DIR="sdlc/features/${FEATURE_ID}"

# 必須ドキュメント
DECISIONS="${FEATURE_DIR}/decisions.md"
RISKS="${FEATURE_DIR}/risks.md"

# オプションドキュメント
DESIGN="${FEATURE_DIR}/20_design.md"
IMPL_PLAN="${FEATURE_DIR}/30_implementation_plan.md"

# Read ツールで読み込む
# - decisions.md (CONFIRMED の部分のみ)
# - risks.md (High/Critical risks を重点的に)
# - 20_design.md (存在する場合)
# - 30_implementation_plan.md (存在する場合)
```

**コード変更を確認**:
```bash
# 現在の git diff を取得
CODE_CHANGES=$(git diff main...HEAD)

# 変更がない場合は警告
if [[ -z "$CODE_CHANGES" ]]; then
    log_warning "コード変更がありません"
fi
```

---

### Step 3: タスク完成度 & 一致性チェック

**目的**: Implementation Plan の完成度と Decision との一致性を検証

#### 3.1 Implementation Plan タスク完成度チェック

**実行内容**:
```bash
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
- **Documentation タスク未完了** → 警告
- **Testing タスク未完了** → 警告（High Risk の場合はブロッカー）
- **Core 実装タスク未完了** → ブロッカー

#### 3.2 一致性チェック

**Decisions との一致**:
- 実装が Chosen Option に従っているか
- Rejected Options を使っていないか
- Non-Negotiables が守られているか

**リスク管理**:
- risks.md に記録されていない新しいリスクがないか
- 高リスクステップの緩和策が実装されているか

**設計との一致**:
- design.md の方針から逸脱していないか
- Invariants（不変条件）が破壊されていないか

**判定基準**:

| 重大度 | 条件 | 対応 |
|-------|------|-----|
| ❌ ブロッカー | - Core実装タスク未完了<br>- Testing タスク未完了（High Risk）<br>- decisions.md から明確に逸脱<br>- Non-Negotiables 違反<br>- 新しい未記録リスク | 修正必須 |
| ⚠️ 警告 | - Documentation タスク未完了<br>- Testing タスク未完了（Low/Medium Risk）<br>- Implementation Plan から若干ずれ<br>- リスク緩和策が不完全 | 推奨修正 |
| ✅ 問題なし | - 全タスク完了<br>- Decisions に従っている<br>- リスク適切管理 | PR 可能 |

---

### Step 4: 結果分析 & 表示

**目的**: チェック結果を表示（ファイルには書き込まない）

**表示内容**:
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

**注意**:
- Self-Check の結果は repository に commit しない
- ターミナルに直接表示のみ
- 問題があれば修正後に再度 `/sdlc-check` を実行

---

## 最適化提案

### 現在の問題点

1. **前提確認欠落**:
   - Feature 存在確認がない
   - ブランチ確認がない

2. **共有スクリプト未使用**:
   - `check_feature_exists()` を使うべき
   - `check-branch.sh` を使うべき
   - `get_metadata_value()` を使うべき（Risk Level 取得など）

3. **ステップの粒度**:
   - Step 5 "結果を表示" は出力のみ、ステップではない

### 最適化案

**5 Steps → 4 Steps**

```
1. 前提確認（Feature 存在 + ブランチ確認）
2. ドキュメント & コード読取（decisions, risks, design, impl_plan, git diff）
3. タスク完成度 & 一致性チェック
4. 結果分析 & 表示（ブロッカー/警告判定、出力）
```

**変更内容**:
- Step 1 前提確認を追加（Feature 存在 + ブランチ確認）
- 共有スクリプトを使用（`check_feature_exists()`, `check-branch.sh`）
- Step 1 と Step 2 を統合（ドキュメント & コード読取）
- Step 5 "結果を表示" を Step 4 に統合（分析と表示を一緒に）

---

## エラーハンドリング

| エラー状況 | 処理 | 使用機能 |
|-----------|------|---------|
| Feature 不存在 | エラー表示して終了 | `check_feature_exists()` |
| ブランチ不一致 | エラー表示して終了 | `check-branch.sh` |
| Decision 未確定 | 警告表示 | `get_metadata_value()` |
| git diff が空 | 警告表示 | - |
| ブロッカーあり | PR 作成不可を表示 | - |

---

## 共有スクリプト活用状況

❌ **未使用** - 共有スクリプトを使用していない

**追加すべき共有スクリプト**:
- `check_feature_exists()` - Feature 存在確認
- `scripts/check-branch.sh` - ブランチ検証
- `get_metadata_value()` - Metadata 値取得（Risk Level など）
- `display_error()` - エラー表示
- `log_info()`, `log_warning()` - ログ出力

**sed 使用**: ❌ なし

---

## 次のステップ

チェック完了後:

**ブロッカーなし**:
1. `/sdlc-pr-code {FEATURE_ID}` - Code Review PR 作成

**ブロッカーあり**:
1. 問題を修正
2. `/sdlc-check {FEATURE_ID}` - 再チェック

---

## 特徴

**このコマンドの特殊性**:
- 唯一、結果をファイルに書き込まない（ターミナル表示のみ）
- 唯一、metadata を更新しない
- Self-Check のため、記録を残さない
- 何度でも実行可能

**Peer Review との違い**:
- Self-Check: `/sdlc-check` → 記録しない
- Peer Review: `/sdlc-pr-design`, `/sdlc-pr-code` → `40_review_findings.md` に記録

---

## 結論

**現状**: 共有スクリプトを全く使用していない、前提確認が欠落

**推奨変更**:
1. 前提確認を追加（Feature 存在 + ブランチ確認）
2. 共有スクリプトを使用（`check_feature_exists()`, `check-branch.sh` など）
3. "結果を表示" を独立ステップから削除

**最終ステップ数**: 5 → **4**
