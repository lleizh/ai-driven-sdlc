# AI-Driven SDLC 状態管理システム完全ガイド

## 1. 状態フィールド一覧

### 1.1 STATUS（7つの値）

| STATUS | 説明 | フェーズ | 設定タイミング |
|--------|------|----------|---------------|
| **planning** | 初期計画段階 | 📋 Planning | `/sdlc-init` |
| **design** | 設計レビュー中 | 🎨 Design | `/sdlc-pr-design` |
| **implementing** | 実装中 | 💻 Implementation | `/sdlc-coding` |
| **testing** | テスト実行中 | 🧪 Testing | `/sdlc-test` |
| **review** | コードレビュー中 | 👀 Review | `/sdlc-pr-code` |
| **blocked** | 作業停止（revision待ち） | ⚠️ Blocked | `/sdlc-revise` |
| **completed** | 完了 | ✅ Done | 自動（PR merge時） |

### 1.2 DECISION_STATUS（3つの値）

| DECISION_STATUS | 説明 | 設定タイミング |
|-----------------|------|---------------|
| **pending** | Decision 未確定 | `/sdlc-init` |
| **confirmed** | Decision 確定済み | `/sdlc-decision` |
| **revised** | Decision 修正中 | `/sdlc-revise` |

### 1.3 その他の重要フィールド

- `RISK_LEVEL`: low / medium / high
- `BRANCH`: feature/{FEATURE_ID}（単一ブランチ設計）
- `PREVIOUS_STATUS`: blocked 前の STATUS（復元用）
- `BLOCKED_REASON`: blocked の理由
- `REVISION_COUNT`: revision の回数
- `CREATED_DATE`, `LAST_UPDATED`: タイムスタンプ

---

## 2. STATUS遷移フロー

### 2.1 通常フロー（Low Risk）

```
planning → implementing → testing → review → completed
  ↓            ↓           ↓          ↓         ↓
/sdlc-init  /sdlc-     /sdlc-test  /sdlc-   Auto
           coding                 pr-code   (merge)
```

### 2.2 通常フロー（Medium/High Risk）

```
planning → design → implementing → testing → review → completed
  ↓          ↓          ↓           ↓          ↓         ↓
/sdlc-   /sdlc-    /sdlc-      /sdlc-test  /sdlc-   Auto
init   pr-design  coding                  pr-code  (merge)
```

### 2.3 Revision フロー（Design Drift 発生時）

```
implementing → blocked → (revision PR) → implementing
     ↓            ↓                            ↓
/sdlc-revise  PREVIOUS_  /sdlc-resume   STATUS復元
             STATUS保存   (DECISION確定後)
```

---

## 3. コマンドとSTATUS管理

| # | コマンド | STATUS更新 | DECISION_STATUS更新 | 備考 |
|---|----------|-----------|-------------------|------|
| 1 | `/sdlc-init` | **planning** | **pending** | Feature初期化 |
| 2 | `/sdlc-pr-design` | **design** | - | Design Review PR作成 |
| 3 | `/sdlc-decision` | - | **confirmed** | Decision確定 |
| 4 | `/sdlc-impl-plan` | - | - | 実装計画生成（任意） |
| 5 | `/sdlc-coding` | **implementing** | - | AI実装開始 |
| 6 | `/sdlc-test` | **testing** | - | テスト実行 |
| 7 | `/sdlc-check` | - | - | 一致性確認（表示のみ） |
| 8 | `/sdlc-pr-code` | **review** | - | Implementation PR作成 |
| 9 | `/sdlc-revise` | **blocked** | **revised** | Decision修正 + PREVIOUS_STATUS保存 |
| 10 | `/sdlc-resume` | **implementing** | - | blocked解除 + STATUS復元 |
| 11 | PR merge | **completed** | - | 自動更新（GitHub Actions） |

---

## 4. GitHub Projects v2 連携

### 4.1 自動同期フィールド

`.metadata` の値が GitHub Projects のカスタムフィールドに自動同期：

| .metadata | GitHub Projects | 型 | 値 |
|-----------|-----------------|----|----|
| STATUS | Status | Single Select | Backlog, Planning, Design, Implementation, Testing, Review, Blocked, Done |
| DECISION_STATUS | Decision Status | Single Select | Pending, Confirmed, Rejected |
| RISK_LEVEL | Risk Level | Single Select | Low, Medium, High |
| FEATURE_ID | Feature ID | Text | FEATURE-XXX |

### 4.2 GitHub Actions Workflows

#### Workflow 1: `auto-add-issues.yml`
- **トリガー**: Issue に `sdlc:track` label 追加
- **動作**: 
  - Issue を Projects の **Backlog** に自動追加
  - STATUS = Backlog に設定
- **Label 削除時**: 
  - `.metadata` 存在確認
  - 存在しない → Projects から削除
  - 存在する → Projects に保持（/sdlc-init 実行済みと判断）

#### Workflow 2: `sync-projects.yml`
- **トリガー**: `.metadata` ファイルの push（develop/feature ブランチ）
- **動作**:
  - 変更された `.metadata` を検出
  - GitHub Projects の対応フィールドを更新
  - STATUS, DECISION_STATUS, RISK_LEVEL, FEATURE_ID を同期

#### Workflow 3: `update-feature-status.yml`
- **トリガー**: develop ブランチへの PR merge
- **動作**:
  - マージコミットから Feature ID 抽出
  - `.metadata` の STATUS を **implementing** → **completed** に更新
  - Git commit & push（`[skip ci]` でループ回避）
  - 次に `sync-projects.yml` がトリガーされ、Projects の STATUS → **Done** に更新

---

## 5. 実際の使用例

### 5.1 通常フロー（Medium Risk）

```bash
# 1. Issue作成 + sdlc:track label
# → Projects に自動追加（Backlog）

# 2. Feature初期化
/sdlc-init https://github.com/owner/repo/issues/123
# STATUS: planning
# DECISION_STATUS: pending
# → Projects: Planning

# 3. Design Review PR
/sdlc-pr-design FEATURE-24
# STATUS: design
# → Projects: Design

# 4. PR merge後、Decision確定
/sdlc-decision FEATURE-24
# DECISION_STATUS: confirmed
# → Projects: Confirmed

# 5. 実装開始
/sdlc-coding FEATURE-24
# STATUS: implementing
# → Projects: Implementation

# 6. テスト実行
/sdlc-test FEATURE-24
# STATUS: testing
# → Projects: Testing

# 7. Implementation PR
/sdlc-pr-code FEATURE-24
# STATUS: review
# → Projects: Review

# 8. PR merge
# → GitHub Actions が自動実行
# STATUS: completed
# → Projects: Done
```

### 5.2 Revision フロー（Design Drift発生）

```bash
# 実装中に設計変更が必要と判明
/sdlc-revise FEATURE-24
# STATUS: blocked
# PREVIOUS_STATUS: implementing
# DECISION_STATUS: revised
# → Projects: Blocked

# Revision PR 作成・マージ後
/sdlc-resume FEATURE-24
# STATUS: implementing (復元)
# PREVIOUS_STATUS: "" (クリア)
# → Projects: Implementation

# 実装再開...
```

---

## 6. .metadata ファイル例

### 6.1 初期状態（/sdlc-init後）

```bash
FEATURE_ID=FEATURE-24
RISK_LEVEL=medium
STATUS=planning
CREATED_DATE=2025-12-27
DECISION_STATUS=pending
ISSUE_URL=https://github.com/owner/repo/issues/123
BRANCH=feature/FEATURE-24
```

### 6.2 実装中

```bash
FEATURE_ID=FEATURE-24
RISK_LEVEL=medium
STATUS=implementing
CREATED_DATE=2025-12-27
LAST_UPDATED=2025-12-27
DECISION_STATUS=confirmed
ISSUE_URL=https://github.com/owner/repo/issues/123
BRANCH=feature/FEATURE-24
```

### 6.3 Blocked状態（Revision中）

```bash
FEATURE_ID=FEATURE-24
RISK_LEVEL=medium
STATUS=blocked
PREVIOUS_STATUS=implementing
BLOCKED_REASON="Decision revision pending review"
BLOCKED_DATE=2025-12-27
CREATED_DATE=2025-12-27
LAST_UPDATED=2025-12-27
DECISION_STATUS=revised
REVISION_COUNT=1
REVISION_1_DATE=2025-12-27
REVISION_1_MAKER=John Doe
REVISION_1_REASON=External API changed
ISSUE_URL=https://github.com/owner/repo/issues/123
BRANCH=feature/FEATURE-24
```

### 6.4 完了状態

```bash
FEATURE_ID=FEATURE-24
RISK_LEVEL=medium
STATUS=completed
CREATED_DATE=2025-12-27
LAST_UPDATED=2025-12-28
DECISION_STATUS=confirmed
ISSUE_URL=https://github.com/owner/repo/issues/123
BRANCH=feature/FEATURE-24
```

---

## 7. 設計原則

### 7.1 Single Source of Truth
- **`.metadata` ファイルが唯一の真実の情報源**
- GitHub Projects は **読み取り専用ダッシュボード**
- Projects での手動変更は `.metadata` push で上書きされる

### 7.2 自動化の範囲
- ✅ **自動**: Issue → Projects 追加（label trigger）
- ✅ **自動**: `.metadata` → Projects 同期（push trigger）
- ✅ **自動**: STATUS → completed（PR merge trigger）
- ❌ **手動不可**: Projects での STATUS 変更

### 7.3 エラー処理
- GitHub Actions は失敗時にログ出力
- API レート制限対策（retry + exponential backoff）
- `.sdlc-config` 不存在時はスキップ（setup未完了と判断）

---

## 8. 統計

- **STATUS値**: 7個（planning → completed）
- **DECISION_STATUS値**: 3個（pending → confirmed/revised）
- **管理コマンド**: 12個
- **GitHub Actions**: 3個（auto-add, sync, update-status）
- **自動化率**: ~80%（手動は Decision 確定のみ）
