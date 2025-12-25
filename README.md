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

- [GitHub CLI](https://cli.github.com/) (`gh`)
- [Claude Code](https://claude.ai/code) または Claude API アクセス

```bash
# GitHub CLI インストール
brew install gh
gh auth login
```

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
implementation_plan.md の Step 1 を実装してください
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
| `/sdlc-init <issue-url>` | SDLC 文書生成 | Issue 作成後 |
| `/sdlc-pr-design <feature-id>` | Design Review PR | 文書完成後 |
| `/sdlc-decision <feature-id>` | Decision 確定 | Team Review 後 |
| `/sdlc-impl-plan <feature-id>` | 実装計画生成 | Decision 確定後 |
| `/sdlc-check <feature-id>` | 一致性チェック | 実装完了後 |
| `/sdlc-pr-code <feature-id>` | Implementation PR | チェック通過後 |

---

## 管理ツール (`sdlc-cli`)

```bash
# Feature 一覧
./sdlc-cli list

# Feature ステータス
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

## リスクレベル別プロセス

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

---

## FAQ

### Q: すべての Feature で Design Review が必要？
**A**: いいえ。Low Risk は Code Review のみ。Medium/High Risk のみ Design Review を実施。

### Q: Decision を変更したい場合は？
**A**: `decisions.md` に REVISED として追記。`/sdlc-impl-plan` で実装計画を再生成。

### Q: テンプレートをカスタマイズできる？
**A**: はい。`sdlc/templates/` 配下のファイルを編集してください。

### Q: 既存プロジェクトに統合できる？
**A**: はい。このリポジトリをコピーまたはサブモジュールとして追加してください。

---

## ライセンス

MIT
