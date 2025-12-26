# AI-Driven SDLC

AI を実行エンジンとして使い、人間が意思決定とリスク管理を行う開発プロセス。

## コンセプト

- **人間が決定、AI が実行**
- **リスク駆動型開発**（低/中/高でプロセスを調整）
- **監査可能**（すべての決定とリスクを記録）
- **軽量運用**（必要最小限のドキュメント）

詳細: [AI_SDLC.md](./AI_SDLC.md)

---

## 前提条件

- [GitHub CLI](https://cli.github.com/) (`gh`) - **必須**
  - SDLC コマンド（`/sdlc-pr-design`, `/sdlc-pr-code` など）で使用
  - `install.sh` 実行時に GitHub Label を自動作成
- [Claude Code](https://claude.ai/code) または Claude API アクセス

```bash
# GitHub CLI インストール
brew install gh

# GitHub 認証（Label 自動作成に必要）
gh auth login
```

**注意**: `gh` コマンドがインストールされていない場合、`install.sh` は GitHub Label の自動作成をスキップします。その場合は手動で Label を作成するか、`gh` をインストール後に `install.sh` を再実行してください。

---

## クイックスタート

### 1. GitHub で Issue を作成

`.github/ISSUE_TEMPLATE/feature.md` を使用：
- Why（なぜ）
- What（何を）
- Risk Level（リスク評価）

### 2. SDLC 文書を生成

Claude Code で実行：
```
/sdlc-init https://github.com/owner/repo/issues/123
```

生成される文書：
- **Low Risk**: Context, Decisions, Risks
- **Medium Risk**: +Requirements, Design, Test Plan
- **High Risk**: +Release Plan

### 3. Design Review PR を作成

```
/sdlc-pr-design FEATURE-123
```

自動的に：
- PR Description を生成
- GitHub PR を作成（`gh pr create`）
- Label: `design-review`

### 4. Decision を確定

チームで議論後、Decision Maker が確定：
```
/sdlc-decision FEATURE-123
```

AI が記録：
- `decisions.md` → Status: CONFIRMED
- `20_design.md` → Status: FROZEN

### 5. 実装計画を生成

```
/sdlc-impl-plan FEATURE-123
```

生成される内容：
- Step 1, Step 2, Step 3... と段階的な実装ステップ
- 高リスクステップに `⚠️` マーク

### 6. 実装

```bash
git checkout -b feature/FEATURE-123
```

Claude Code で対話しながら実装：
```
30_implementation_plan.md の Step 1 を実装してください
```

### 7. PR 前チェック

```
/sdlc-check FEATURE-123
```

チェック内容：
- Decisions との一致性
- 未記録リスクの有無
- Invariants の確認

結果を `40_review_findings.md` に記録。

### 8. Implementation PR を作成

```
/sdlc-pr-code FEATURE-123
```

自動的に：
- PR Description を生成
- GitHub PR を作成
- Label: `implementation`

---

## コマンド一覧

| コマンド | 説明 | 使用タイミング |
|---------|------|--------------|
| `/sdlc-issue` | 対話から Issue 作成 | 対話中に Issue 化したい時 |
| `/sdlc-init <issue-url>` | SDLC 文書生成 | Issue 作成後 |
| `/sdlc-pr-design <feature-id>` | Design Review PR | 文書完成後 |
| `/sdlc-decision <feature-id>` | Decision 確定 | Team Review 後 |
| `/sdlc-impl-plan <feature-id>` | 実装計画生成 | Decision 確定後 |
| `/sdlc-coding <feature-id>` | 実装実行 | Decision 確定後 |
| `/sdlc-revise <feature-id>` | Decision 修正（Design Drift） | 実装中に前提崩壊時 |
| `/sdlc-check <feature-id>` | 一致性チェック | 実装完了後 |
| `/sdlc-pr-code <feature-id>` | Implementation PR | チェック通過後 |

---

## 管理ツール (`sdlc-cli`)

### 基本コマンド

```bash
# Feature 一覧
./sdlc-cli list

# Feature ステータス（フェーズ進捗付き）
./sdlc-cli status FEATURE-123

# Decision ステータス更新
./sdlc-cli decision FEATURE-123 confirmed

# リスクレベル変更
./sdlc-cli risk FEATURE-123 high

# 検証
./sdlc-cli validate FEATURE-123

# レポート
./sdlc-cli report
```

---

## ディレクトリ構造
```
.
├── AI_SDLC.md                      # プロセス定義
├── README.md                       # このファイル
├── sdlc-cli                        # 管理ツール
├── .claude/commands/               # Claude Code コマンド
│   ├── sdlc-init.md
│   ├── sdlc-pr-design.md
│   ├── sdlc-decision.md
│   ├── sdlc-impl-plan.md
│   ├── sdlc-check.md
│   └── sdlc-pr-code.md
├── .github/
│   └── ISSUE_TEMPLATE/
│       └── feature.md              # Issue テンプレート
└── sdlc/
    ├── templates/                  # 文書テンプレート
    │   ├── 00_context.md
    │   ├── 10_requirements.md
    │   ├── 20_design.md
    │   ├── 30_implementation_plan.md
    │   ├── 40_review_findings.md
    │   ├── 50_test_plan.md
    │   ├── 60_release_plan.md
    │   ├── decisions.md
    │   └── risks.md
    └── features/                   # Feature 文書（生成される）
        └── FEATURE-123/
            ├── .metadata
            ├── 00_context.md
            ├── decisions.md
            ├── risks.md
            └── ...
```

---

### Low Risk
- **文書**: Context, Decisions, Risks
- **Review**: Code Review のみ
- **例**: バグ修正、UI 微調整

### Medium Risk
- **文書**: +Requirements, Design, Test Plan
- **Review**: Design Review（推奨）+ Code Review
- **例**: 新機能追加、サブシステム変更

### High Risk
- **文書**: +Implementation Plan, Release Plan
- **Review**: Design Review（必須）+ Code Review
- **例**: システム全体への影響、認証・課金システム

---

## 三原則（Iron Rules）

1. **Issue がなければコードを書かない**
2. **CONFIRMED な decisions.md がなければ実装しない**
3. **記録されていないリスクは未評価とみなす**

---

## ワークフロー例

### 標準フロー（Happy Path）

```bash
# 1. GitHub で Issue 作成
# https://github.com/owner/repo/issues/123

# 2. SDLC 文書生成
/sdlc-init https://github.com/owner/repo/issues/123

# 3. 文書を編集・調整
cd sdlc/features/FEATURE-123/
vim 00_context.md
vim decisions.md

# 4. Design Review PR
/sdlc-pr-design FEATURE-123

# 5. Team Review（GitHub PR で議論）
# レビュアーは以下だけ読めばOK（15-30分）:
#   - Issue (GitHub)
#   - decisions.md (PENDING)
#   - risks.md
#   - 20_design.md (DRAFT、存在する場合)

# 6. Decision 確定
/sdlc-decision FEATURE-123

# 7. Design PR マージ

# 8. 実装計画生成
/sdlc-impl-plan FEATURE-123

# 9. 実装
git checkout -b feature/FEATURE-123
# Claude Code で実装...

# 10. チェック
/sdlc-check FEATURE-123

# 11. Implementation PR
/sdlc-pr-code FEATURE-123

# 12. Code Review & マージ
```

### Decision Revision フロー（前提崩壊時）

実装中に「設計の前提が成り立たない」場合：

```bash
# 実装中に問題発見
# 例: 外部 API が想定と異なる、技術的制約が判明

# 1. Decision を修正
/sdlc-revise FEATURE-123

# 入力内容:
# - Why Revise: なぜ変更が必要か
# - What Changed: 何を変更したか
# - Impact Scope: 影響範囲（ファイル/モジュール名）
# - New Risks: 新しいリスク
# - Decision Maker: あなたの名前

# 2. 実装計画を再生成（必要に応じて）
/sdlc-impl-plan FEATURE-123

# 3. チームに共有
# Slack/メール等で変更内容を通知

# 4. 実装を続行
# 修正された決定に基づいて実装

# 5. チェック
/sdlc-check FEATURE-123

# 6. Implementation PR
/sdlc-pr-code FEATURE-123
```

**重要**: Revision は例外処理です。頻発する場合は設計の根本的な見直しを検討してください。

---

## FAQ

### Q: すべての Feature で Design Review が必要？
**A**: いいえ。Low Risk は Code Review のみ。Medium/High Risk のみ Design Review を実施。

### Q: Design Review は時間がかかる？
**A**: いいえ。必読は **Issue + decisions.md + risks.md + design.md** の4つのみ（15-30分）。他は optional です。

### Q: Decision を変更したい場合は？
**A**: `/sdlc-revise <feature-id>` を使用。理由・変更内容・影響範囲を記録し、`decisions.md` に REVISED として追記されます。

### Q: 実装中に設計の前提が崩れたらどうする？
**A**: すぐに `/sdlc-revise` を実行。なぜ変更が必要か、何を変えるか、影響範囲を明記してください。頻発する場合は設計を根本から見直すサインです。

### Q: Revision は何回まで許容される？
**A**: 0-1回は正常、2-3回は要注意、4回以上は設計の見直しを推奨。

### Q: テンプレートをカスタマイズできる？
**A**: はい。`sdlc/templates/` 配下のファイルを編集してください。

### Q: 既存プロジェクトに統合できる？
**A**: はい。`install.sh` で簡単にインストールできます。

---

## 既存プロジェクトへの適用

```bash
cd your-project

# フルインストール
curl -fsSL https://raw.githubusercontent.com/lleizh/ai-driven-sdlc/master/install.sh | bash

# 確認のみ（dry run）
curl -fsSL https://raw.githubusercontent.com/lleizh/ai-driven-sdlc/master/install.sh | bash -s -- --dry-run
```

**ローカルで実行する場合**：
```bash
git clone https://github.com/lleizh/ai-driven-sdlc
cd your-project
/path/to/ai-driven-sdlc/install.sh
```

**オプション**：
- `--force` - 既存ファイルを強制上書き
- `--update` - 既存ファイルごとに上書き確認
- `--dry-run` - 実行せず確認のみ

---

## ライセンス

MIT
