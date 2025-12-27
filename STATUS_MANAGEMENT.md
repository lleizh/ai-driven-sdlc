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
