# /sdlc-impl-plan - 流程整理

## 文档依据

- **AI_SDLC.md**: Decision 確定後に実装計画を生成、設計を再議論しない
- **SDLC_FLOW.md**: Step 7 - 実装計画を生成（任意、推奨：中/高、必須：高）
- **STATUS_MANAGEMENT.md**: STATUS は変更しない（planning のまま）

---

## 命令目的

Decision 確定後、実装計画を生成する。

**重要**: このコマンドは任意（推奨：中/高、必須：高）

---

## 前提条件

**必須**:
- ✅ Feature が存在
- ✅ DECISION_STATUS = confirmed

**非必須**:
- Design Review 完了済み（中/高リスクの場合）

---

## 実行フロー

### 1. 前提確認

```bash
source scripts/common-functions.sh

# Feature 存在確認
check_feature_exists "$FEATURE_ID" || exit 1

# ブランチ確認
scripts/check-branch.sh "$FEATURE_ID" || exit 1

# Decision Status 確認
DECISION_STATUS=$(get_metadata_value "$FEATURE_ID" "DECISION_STATUS")

if [[ "$DECISION_STATUS" != "confirmed" ]]; then
    display_error \
        "Decision が CONFIRMED ではありません" \
        "現在: ${DECISION_STATUS}" \
        "/sdlc-decision ${FEATURE_ID} で Decision を確定してください"
    exit 1
fi
```

**目的**: 
- Feature 存在確認
- ブランチ確認
- Decision Status 確認（CONFIRMED であることを確認）

---

### 2. ドキュメント読取

Read ツールで以下のファイルを読み取る：

**必須**:
- `.metadata` - Feature ID、Risk Level、Status
- `00_context.md` - Goals、Constraints、Success Metrics
- `decisions.md` - CONFIRMED 済みの Chosen Options、Rationale
- `risks.md` - High/Medium Risk とその緩和策

**オプション**:
- `20_design.md` - Architecture、Component Design（存在する場合）

**目的**: Implementation Plan 生成のためのデータ収集

---

### 3. テンプレート読取

```bash
TEMPLATE="sdlc/templates/30_implementation_plan.md"

if [[ ! -f "$TEMPLATE" ]]; then
    log_error "テンプレートが見つかりません: ${TEMPLATE}"
    exit 1
fi
```

**目的**: Implementation Plan のテンプレートを読み込む

---

### 4. Implementation Plan 生成

テンプレートに以下の内容を埋める：

#### Overview セクション
- Context の Goals を要約
- Decisions の Chosen Options を列挙
- Risk Level を明記

#### Implementation Phases セクション

**Phase 分割の原則**:
1. **Phase 1**: 基礎インフラ・共通機能（他の Phase が依存）
2. **Phase 2**: コア機能の実装
3. **Phase 3**: 統合とテスト
4. **Phase 4**: ドキュメントと仕上げ

**タスクの構造**:
```markdown
- [ ] Task 1: {具体的なタスク}
  - File: {対象ファイルパス}
  - Description: {詳細説明}
  - Acceptance: {完了条件}
```

**タスクの粒度**: 1タスク = 1-2時間で完了できる単位

**高リスクタスクのマーク**:
```markdown
- [ ] ⚠️ Task 5: データマイグレーション
  - Risk: データ損失の可能性（risks.md #3）
  - Mitigation: バックアップを事前に作成、ロールバック手順を準備
```

#### Testing Strategy セクション
- Unit Tests、Integration Tests、E2E Tests の計画
- Target Coverage: {目標カバレッジ率}

#### Risks and Mitigation セクション
- risks.md の High/Medium Risk を転記
- 各リスクに対する緩和策
- Related Tasks: Phase {N} Task {M}

#### Timeline セクション
- 各 Phase の推定工数
- 総タスク数と総時間

**重要な原則**（AI_SDLC.md 準拠）:
- ✅ Decisions の内容を厳守、勝手に変更しない
- ✅ 設計を再議論しない
- ✅ 具体的なファイル名・関数名を記載
- ✅ テストタスクを含める

---

### 5. ファイル書込

Write ツールで生成した内容を書き込む：
```
sdlc/features/{FEATURE_ID}/30_implementation_plan.md
```

---

### 6. Metadata 更新

```bash
scripts/update-metadata.sh "$FEATURE_ID" "LAST_UPDATED" "$(date +%Y-%m-%d)"
```

**変更内容**:
- `LAST_UPDATED`: 現在の日付

**注意**: STATUS は変更しない（planning のまま）

---

### 7. Commit と Push

```bash
ISSUE_URL=$(get_metadata_value "$FEATURE_ID" "ISSUE_URL")
ISSUE_NUMBER=$(echo "$ISSUE_URL" | grep -oE '[0-9]+$')

git add "sdlc/features/${FEATURE_ID}/30_implementation_plan.md"
git add "sdlc/features/${FEATURE_ID}/.metadata"

git commit -m "docs(${FEATURE_ID}): generate implementation plan

Based on confirmed decisions

Related: #${ISSUE_NUMBER}"

git push origin "feature/${FEATURE_ID}"
```

**Commit メッセージ形式**:
- タイトル: `docs({FEATURE_ID}): generate implementation plan`
- 本文: `Based on confirmed decisions`
- Footer: `Related: #{ISSUE_NUMBER}`

---

## 状態変化

### 30_implementation_plan.md
- **作成前**: 不存在
- **作成後**: 実装計画が生成される（Phases、Tasks、Timeline）

### .metadata
- **LAST_UPDATED**: 更新
- **STATUS**: 変更なし（planning のまま）

### GitHub Projects
- **変化なし**: STATUS が変わらないため、Projects の状態も変わらない

---

## 完了メッセージ

```
✅ Implementation Plan を生成しました

📋 計画情報:
- ファイル: sdlc/features/{FEATURE_ID}/30_implementation_plan.md
- Phases: {Phase数}
- Tasks: {タスク数}
- Estimated Effort: {総時間}

⚠️  高リスクタスク: {数}
{高リスクタスクがある場合、リスト表示}

次のステップ:
1. Implementation Plan を確認
2. /sdlc-coding {FEATURE_ID} で実装を開始
```

---

## エラー処理

### Feature 不存在
```
❌ エラー: Feature が見つかりません: {FEATURE_ID}

Action: /sdlc-init {Issue URL} を先に実行してください
```

### ブランチ不一致
```
❌ エラー: ブランチが一致しません

現在: {current_branch}
必要: feature/{FEATURE_ID}

Action: git checkout feature/{FEATURE_ID}
```

### Decision 未確定
```
❌ エラー: Decision が CONFIRMED ではありません

現在: {DECISION_STATUS}

Action: /sdlc-decision {FEATURE_ID} で Decision を確定してください
```

### テンプレート不存在
```
❌ エラー: テンプレートが見つかりません

Context: sdlc/templates/30_implementation_plan.md

Action: テンプレートファイルを確認してください
```

---

## AI_SDLC.md との整合性

✅ **Decision 確定後に実装計画を生成**:
- DECISION_STATUS が confirmed であることを確認

✅ **設計を再議論しない**:
- Decisions の Chosen Options に厳密に従う
- 新しい選択肢を提案しない

✅ **実装計画は任意**:
- 推奨: 中/高リスク
- 必須: 高リスク

---

## SDLC_FLOW.md との整合性

✅ **Step 7**: /sdlc-impl-plan（任意）
- 実装計画を生成
- 30_implementation_plan.md

✅ **次のステップ**: Step 8 - /sdlc-coding

---

## STATUS_MANAGEMENT.md との整合性

✅ **STATUS 変更なし**:
- このコマンドでは STATUS を変更しない
- planning のまま

✅ **.metadata 更新**:
- `LAST_UPDATED` のみ更新 ✅

✅ **次の STATUS**: 
- `/sdlc-coding` → `implementing`

---

## 共有スクリプトの使用

✅ **使用している共有スクリプト**:
- `source scripts/common-functions.sh`
- `check_feature_exists()` - Feature 存在確認
- `get_metadata_value()` - Metadata 値取得
- `display_error()` - エラー表示
- `scripts/update-metadata.sh` - Metadata 更新

**評価**: ✅ 完璧に共有スクリプトを活用している

---

## 流程評価

### ✅ 合理的な点

1. **前提確認が完全**
   - Feature、ブランチ、Decision Status を確認

2. **共有スクリプトを完全活用**
   - すべての共通処理で共有スクリプトを使用

3. **Decisions に厳密に従う**
   - AI_SDLC.md の原則に準拠

---

### ⚠️ 確認点

**Q1**: ブランチ確認は必要か？

**考察**:
- Implementation Plan は実装前の計画
- ブランチは `/sdlc-init` で作成済み
- ファイルを書き込むので、ブランチ確認は**必要**

**判断**: ✅ 必要（追加すべき）

---

**Q2**: STATUS を変更しないのは正しいか？

**考察**:
- Implementation Plan は計画段階
- 実装は `/sdlc-coding` で開始
- STATUS は `/sdlc-coding` で `implementing` に変更

**判断**: ✅ 正しい

---

### 改善提案

**優先度 中: ブランチ確認を追加**

**現状**: ブランチ確認がない

**改善後**:
```bash
# Step 1: 前提確認
check_feature_exists "$FEATURE_ID" || exit 1
scripts/check-branch.sh "$FEATURE_ID" || exit 1  # 追加
```

---

## まとめ

### このコマンドの役割
1. Decision 確定後に実装計画を生成
2. Phases、Tasks、Timeline を詳細化
3. 高リスクタスクを可視化

### ステップ数
- **7 ステップ**（適切）
- シンプルで明確

### 優化の必要性
- ⚠️ **ブランチ確認を追加**（推奨）
- ✅ その他は完璧

### 次のステップ
- `/sdlc-coding` で実装開始
- STATUS が `implementing` に変更される
