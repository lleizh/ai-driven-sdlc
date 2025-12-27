# Command: /sdlc-revise

実装中に設計の前提が崩れた場合、Decision を修正し影響範囲を記録します。

## 使用方法

```
/sdlc-revise <feature-id>
```

実行時、以下の情報を入力してください：
- **Why Revise**（なぜ変更が必要か）
- **What Changed**（何を変更したか）
- **Impact Scope**（影響範囲：ファイル/モジュール名）
- **New Risks**（新しく発生したリスク）
- **Decision Maker**（あなたの名前）

## 実行内容

### 1. 前提条件チェック

- ✅ Feature が存在する
- ✅ `decisions.md` が **CONFIRMED** 状態
- ✅ 実装フェーズである

### 2. REVISED エントリを追加

`decisions.md` に以下を**追記**（元の CONFIRMED は残す）：

```markdown
---

## Decision Revision {連番}

**Status**: REVISED
**Date**: {今日の日付}
**Decision Maker**: {名前}

### Why Revise（変更理由）
{ユーザー入力}

### What Changed（変更内容）
**Before**: {元の決定}
**After**: {新しい決定}

### Impact Scope（影響範囲）
{ユーザー入力}

### Accepted Risks
{新たに受け入れるリスク}
```

### 3. 関連ファイルを更新

#### 3.1 `risks.md` の更新（New Risks がある場合）

**追加位置**: "Detailed Risk Analysis" セクションの末尾

**フォーマット**: `sdlc/templates/risks.md` の Risk 詳細セクションに従う

**追加フィールド**: 
```markdown
**Introduced By**: Decision Revision #{連番}
```

**同時更新**: ファイル冒頭の "Risk Assessment Summary" テーブルにも新行を追加

#### 3.2 `30_implementation_plan.md` の更新

ファイル冒頭（`# Implementation Plan` の前）に Revision Alert を追加：

```markdown
> ⚠️ **Revision Alert**: This plan was revised on {DATE} due to design changes.  
> See [Decision Revision #{N}](decisions.md#decision-revision-{N}) for details.
```

**複数回 Revision の場合**: 既存の Alert の下に追加

#### 3.3 `20_design.md` の更新（存在する場合）

**Status の更新**:
```markdown
**Status**: APPROVED → REVISED
```

**Revision History の追加**:
ファイル末尾（`## References` の前）に追加：

```markdown
---

## Revision History

### Revision #{連番} - {DATE}
**Decision Maker**: {名前}  
**Reason**: {Why Revise}  
**Changes**: {What Changed}  
**Impact Scope**: {Impact Scope}  
**Related Decision**: [Decision Revision #{連番}](decisions.md#decision-revision-{連番})
```

**複数回 Revision の場合**: 新しいエントリを末尾に追加

#### 3.4 `.metadata` の更新

以下のフィールドを追加/更新：

```bash
# 現在の STATUS を保存
PREVIOUS_STATUS=$STATUS

# blocked 状態に設定
STATUS=blocked
BLOCKED_REASON="Decision revision pending review"
BLOCKED_DATE={YYYY-MM-DD}

# Revision 情報
REVISION_COUNT={N}
REVISION_{N}_DATE={YYYY-MM-DD}
REVISION_{N}_MAKER={Decision Maker}
REVISION_{N}_REASON={Why Revise の1行要約}

# Decision 状態を更新
DECISION_STATUS=revised
LAST_UPDATED={YYYY-MM-DD}
```

**例** (2回目の Revision):
```bash
PREVIOUS_STATUS=implementing
STATUS=blocked
BLOCKED_REASON="Decision revision pending review"
BLOCKED_DATE=2025-12-25

REVISION_COUNT=2
REVISION_2_DATE=2025-12-25
REVISION_2_MAKER=Jane Smith
REVISION_2_REASON=External API changed

DECISION_STATUS=revised
```

### 4. Commit と Push

```bash
# 全ての変更を commit
git add sdlc/features/${FEATURE_ID}/

git commit -m "docs(${FEATURE_ID}): Decision Revision #${N}

${Why Revise}

Decision Maker: ${DECISION_MAKER}
Impact Scope: ${IMPACT_SCOPE}

Related: #<issue-number>"

git push origin feature/${FEATURE_ID}
```

### 5. Revision PR の判断基準

変更の大きさに応じて PR を作成するか判断：

**大きな変更**（Revision PR 必須）:
- アーキテクチャの変更
- API 設計の変更
- データモデルの変更
- High Risk の導入
- 複数モジュールへの影響

**小さな変更**（PR 不要、feature ブランチで続行）:
- 実装の詳細変更のみ
- パフォーマンス最適化の手法
- Low/Medium Risk のみ
- 単一モジュールへの影響

### 6. Revision PR 作成（大きな変更の場合）

```bash
gh pr create \
  --title "Revision: {FEATURE_ID} - Decision Revision #{N}" \
  --body "{Revision の詳細}" \
  --label "decision-revision" \
  --base develop
```

### 7. 完了メッセージ

```
✅ Decision Revision {連番} を記録しました

📋 更新されたファイル:
- decisions.md (REVISED エントリ追加)
- risks.md (新リスク追加)
- 30_implementation_plan.md (Revision Alert 追加)
- 20_design.md (Status: REVISED)
- .metadata (STATUS=blocked, DECISION_STATUS=revised)

⚠️ 実装を一時停止してください

現在の状態:
- STATUS: blocked
- PREVIOUS_STATUS: {元の STATUS}
- DECISION_STATUS: revised

⚠️ 次のアクション:
【変更が大きい場合】
1. Revision PR をチームレビュー
2. PR マージ後、実装を再開:
   /sdlc-resume {FEATURE_ID}

【変更が小さい場合】
1. チームに変更内容を共有
2. 確認後、実装を再開:
   /sdlc-resume {FEATURE_ID}

注意: blocked 状態が解除されるまで、実装を進めないでください
```

---

## 制約

- 元の CONFIRMED decision は削除しない（追記のみ）
- 自動でコードを修正しない
- Revision は例外処理（頻発する場合は設計見直し）

---

## いつ使うべきか

✅ **使うべき場合**：
- 技術的制約が後から判明
- 外部サービスの仕様変更
- 実装中に設計の欠陥が判明

❌ **使わない場合**：
- 単なるリファクタリング
- 新機能の追加（スコープクリープ）
- 軽微なバグ修正

### Revision 頻度の目安
- **0-1回**: 健全
- **2-3回**: 要注意
- **4回以上**: 設計の根本的な見直しが必要

---

## エラー処理

- Feature 不存在 → `❌ /sdlc-init を先に実行`
- decisions.md が PENDING → `❌ /sdlc-decision を先に実行`
