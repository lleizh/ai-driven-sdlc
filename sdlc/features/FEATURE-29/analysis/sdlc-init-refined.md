# /sdlc-init - 流程整理

## 文档依据

- **AI_SDLC.md**: SDLC 文書は repository で管理、Decision は PENDING で開始
- **SDLC_FLOW.md**: Step 2 - AI が SDLC 草稿を生成
- **STATUS_MANAGEMENT.md**: STATUS = planning、DECISION_STATUS = pending

---

## 命令目的

GitHub Issue から SDLC 文書を自動生成し、Feature の基礎を構築する。

---

## 前提条件

**必須**:
- ✅ GitHub Issue が存在（`/sdlc-issue` で作成済み）
- ✅ Issue に Why/What/Risk Level が記載されている
- ✅ 現在のブランチは `develop`（推奨）

**非必須**:
- Feature ディレクトリは未存在（新規作成）
- Feature ブランチは未作成（このコマンドで作成）

---

## 実行フロー

### 1. Issue を取得

```bash
# Issue URL から owner/repo/number を抽出
# 例: https://github.com/owner/repo/issues/123

gh issue view {number} \
  --repo {owner/repo} \
  --json title,body,labels,comments
```

**取得内容**:
- `title`: Issue タイトル
- `body`: Issue 本文（Why/What/How/Risk Level）
- `labels`: ラベル（feature, high-risk など）
- `comments`: コメント（オプション）

---

### 2. Feature ID を抽出

**優先順位**:
1. Issue 本文から `FEATURE-XXX` を抽出
2. なければ `FEATURE-{Issue番号}` を使用

**例**:
- Issue #123 → Feature ID = `FEATURE-123`
- Issue 本文に "FEATURE-42" → Feature ID = `FEATURE-42`

---

### 3. Risk Level を判定

**判定ロジック**（優先順位）:

1. **Issue 本文の Risk Level checkbox**:
   ```markdown
   ## Risk Level
   - [x] **High**: データ損失リスク
   - [ ] **Medium**: ...
   - [ ] **Low**: ...
   ```
   → チェックされている項目を採用

2. **Issue の labels**:
   - `high-risk` → High
   - `feature` → Medium（デフォルト）
   - `bug` → Low

3. **デフォルト**: Medium

---

### 4. Git ブランチ作成

```bash
# develop に切り替え
git checkout develop

# 最新を取得
git pull origin develop

# Feature ブランチを作成
git checkout -b feature/{FEATURE_ID}
```

**ブランチ命名規則**: `feature/{FEATURE_ID}`
- 例: `feature/FEATURE-123`

**重要**: 単一ブランチ設計
- 1 Feature = 1 Branch
- Design Review も Implementation も同じブランチを使用

---

### 5. ディレクトリ作成

```bash
mkdir -p sdlc/features/{FEATURE_ID}
```

---

### 6. .metadata を作成

**ファイルパス**: `sdlc/features/{FEATURE_ID}/.metadata`

**フィールド**（STATUS_MANAGEMENT.md 準拠）:
```
FEATURE_ID={FEATURE_ID}
RISK_LEVEL={low|medium|high}
STATUS=planning
CREATED_DATE={YYYY-MM-DD}
DECISION_STATUS=pending
ISSUE_URL={Issue URL}
BRANCH=feature/{FEATURE_ID}
```

**重要**:
- `STATUS=planning` - 初期状態
- `DECISION_STATUS=pending` - Decision 未確定

---

### 7. テンプレート読取 & 文書生成

**Risk Level に応じたファイル**:

| Risk Level | 生成ファイル |
|------------|-------------|
| **Low** | `00_context.md`, `decisions.md`, `risks.md` |
| **Medium** | Low + `10_requirements.md`, `20_design.md`, `50_test_plan.md` |
| **High** | Medium + `60_release_plan.md` |

**注意**: `30_implementation_plan.md` は `/sdlc-impl-plan` で生成（Decision 確定後）

---

#### 7.1 プレースホルダーを埋める

各テンプレートの共通プレースホルダー:
- `{FEATURE_ID}` → Feature ID
- `{ISSUE_LINK}` → Issue URL
- `{DATE}` → 今日の日付 (YYYY-MM-DD)

---

#### 7.2 Issue 内容をマッピング

##### `00_context.md`

| セクション | Issue からのマッピング |
|-----------|----------------------|
| Background | Issue の **Why** セクション |
| Problem Statement | Issue で解決すべき問題 |
| Goals | Issue の **What** セクション |
| Non-Goals | Issue の Scope に記載された Out of Scope |
| Constraints | 技術的・ビジネス的制約（Issue から抽出） |
| Success Metrics | Acceptance Criteria を測定可能な形式に |

##### `decisions.md`

**重要な原則**（AI_SDLC.md 準拠）:
- 各 Decision の Status は **必ず PENDING** にする
- Issue で不明確な点や選択肢がある部分を Decision として記載
- Options を複数提示し、Pros/Cons を記載
- Issue に How が記載されている場合も、それを Option A として提示（他の選択肢も検討）

**Decision 抽出例**:
- 技術スタック選択（React vs Vue）
- アーキテクチャ選択（Monolithic vs Microservices）
- データストア選択（SQL vs NoSQL）

##### `risks.md`

**マッピング**:
- Issue の Risk Level セクションから抽出
- 技術的リスク、データリスク、運用リスクを識別

---

#### 7.3 重要な原則

**DO（すべきこと）**:
- ✅ テンプレート構造を厳守
- ✅ Issue の範囲を厳守
- ✅ decisions.md の Status は必ず PENDING
- ✅ 不明確な点は decisions.md に記載
- ✅ 事実確認が必要な点は context に TBD と記載

**DON'T（してはいけないこと）**:
- ❌ テンプレートにないセクションを追加（Assumptions, Open Questions など）
- ❌ Issue に書かれていない機能を勝手に追加
- ❌ Decision を CONFIRMED にする（人間が決定する）

---

### 8. ファイル書込

Write ツールで各ファイルに書き込む:
- `sdlc/features/{FEATURE_ID}/.metadata`
- `sdlc/features/{FEATURE_ID}/00_context.md`
- `sdlc/features/{FEATURE_ID}/decisions.md`
- `sdlc/features/{FEATURE_ID}/risks.md`
- その他（Risk Level に応じて）

---

### 9. 初期 Commit と Push

```bash
# 生成された全ファイルを add
git add sdlc/features/${FEATURE_ID}/

# 初期 commit
git commit -m "docs: Generate SDLC documents for ${FEATURE_ID}

Generated from Issue: ${ISSUE_URL}
Risk Level: ${RISK_LEVEL}

Related: #${ISSUE_NUMBER}"

# ブランチを push
git push -u origin feature/${FEATURE_ID}
```

**Commit メッセージ形式**:
- タイトル: `docs: Generate SDLC documents for {FEATURE_ID}`
- 本文: Issue URL、Risk Level
- Footer: `Related: #{ISSUE_NUMBER}`

---

### 10. 完了メッセージ

```
✅ SDLC 文書を生成しました

📋 生成情報:
- Issue: {URL}
- Feature ID: {ID}
- Branch: feature/{ID}
- Risk Level: {level}
- 生成ファイル数: {数}

📝 次のステップ:

【低リスク】
1. 生成された文書を確認
2. `/sdlc-decision {ID}` で Decision を確定
3. `/sdlc-coding {ID}` で実装開始

【中/高リスク】
1. 生成された文書を確認
2. `/sdlc-pr-design {ID}` で Design Review PR を作成
3. Design Review 完了後、`/sdlc-decision {ID}` で Decision を確定
4. `/sdlc-coding {ID}` で実装開始

⚠️ 注意:
- decisions.md の Status は全て PENDING です
- チームで議論して CONFIRMED/REJECTED を決定してください
```

**重要**: メッセージ表示後、停止。追加の提案や実装コードは生成しない。

---

## 状態変化

### Feature ディレクトリ
- **作成前**: 不存在
- **作成後**: `sdlc/features/{FEATURE_ID}/` 作成、3-7 個のファイル生成

### .metadata
- **作成**: 新規作成
- **STATUS**: `planning`
- **DECISION_STATUS**: `pending`

### Git
- **ブランチ**: `feature/{FEATURE_ID}` 作成
- **Commit**: 初期 commit 作成
- **Push**: リモートにブランチ作成

### GitHub Projects
- **変化なし**: このコマンドでは `.metadata` を push するが、STATUS は変わらない（planning のまま）
- **次回同期**: 次の `.metadata` 更新時に `sync-projects.yml` が実行

---

## エラー処理

### Issue 取得失敗
```
❌ エラー: Issue を取得できませんでした

Context: {エラー詳細}
Action: Issue URL が正しいか確認してください
```

### Feature 既存
```
❌ エラー: Feature が既に存在します

Context: sdlc/features/{FEATURE_ID}/ が既に存在
Action: 
- 既存 Feature を削除: rm -rf sdlc/features/{FEATURE_ID}/
- 別の Feature ID を使用
```

### ブランチ既存
```
❌ エラー: ブランチが既に存在します

Context: feature/{FEATURE_ID} が既に存在
Action:
- 既存ブランチを削除: git branch -D feature/{FEATURE_ID}
- 既存ブランチを使用: git checkout feature/{FEATURE_ID}
```

### テンプレート不存在
```
❌ エラー: テンプレートが見つかりません

Context: sdlc/templates/{ファイル名}
Action: テンプレートディレクトリを確認してください
```

---

## AI_SDLC.md との整合性

✅ **原則 2**: SDLC 文書は repository で管理
- このコマンドで SDLC 文書を repository に作成

✅ **原則 3**: Decision は人間が行い、AI はドラフトと実行を担う
- decisions.md は PENDING で作成（AI がドラフト）
- `/sdlc-decision` で人間が CONFIRMED にする

✅ **三原則 2**: CONFIRMED な decisions.md がなければ実装しない
- このコマンドでは PENDING で作成 → 実装はまだ開始できない

---

## SDLC_FLOW.md との整合性

✅ **Step 2**: /sdlc-init (AI が SDLC 草稿を生成)
- 生成ファイル: context, decisions (PENDING), risks, requirements, design, test_plan, release_plan
- ブランチ: feature/{FID}

✅ **次のステップ**: Risk Level に応じて分岐
- 低リスク → `/sdlc-decision`
- 中/高リスク → `/sdlc-pr-design`

---

## STATUS_MANAGEMENT.md との整合性

✅ **STATUS 遷移**:
```
Backlog (Projects) → planning
                        ↓
                    /sdlc-init
```

✅ **.metadata フィールド**:
- `STATUS=planning` ✅
- `DECISION_STATUS=pending` ✅
- `RISK_LEVEL={low|medium|high}` ✅
- `BRANCH=feature/{FEATURE_ID}` ✅

✅ **次の STATUS**: 
- Low Risk → `implementing` (`/sdlc-coding`)
- Medium/High Risk → `design` (`/sdlc-pr-design`)

---

## 共有スクリプトの使用

**現状**: ❌ 共有スクリプトを使用していない

**改善案**:
- Feature 存在確認は不要（新規作成）
- ただし、既存チェックに使用可能

**推奨**:
```bash
source scripts/common-functions.sh

# Feature が既に存在する場合はエラー
FEATURE_DIR="sdlc/features/${FEATURE_ID}"
if [[ -d "$FEATURE_DIR" ]]; then
    log_error "Feature が既に存在します: ${FEATURE_ID}"
    exit 1
fi

# 処理開始
log_info "Generating SDLC documents for ${FEATURE_ID}..."

# 成功
log_success "SDLC documents generated successfully"
```

---

## まとめ

### このコマンドの役割
1. GitHub Issue から SDLC 文書を自動生成
2. Feature の基礎構築（ディレクトリ、ブランチ、.metadata）
3. Decision を PENDING で作成（人間の判断を待つ）

### 次のステップ
- **Low Risk**: `/sdlc-decision` → `/sdlc-coding`
- **Medium/High Risk**: `/sdlc-pr-design` → Design Review → `/sdlc-decision` → `/sdlc-coding`

### 重要な制約
- decisions.md は必ず PENDING で作成
- テンプレート構造を厳守
- Issue の範囲を超えない
