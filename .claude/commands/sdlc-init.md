# Command: /sdlc-init

GitHub Issue から SDLC 文書を自動生成します。

## 使用方法

```
/sdlc-init <github-issue-url>
```

## 実行内容

1. **Issue を取得**
   ```bash
   gh issue view {number} --repo {owner/repo} --json title,body,labels,comments
   ```

2. **Feature ID を抽出**
   - Issue タイトル/本文から `FEATURE-XXX` を抽出
   - なければ `FEATURE-{Issue番号}` を使用

3. **Risk Level を判定**
   - Issue の Risk Level checkbox から判定
   - チェックがなければ labels から判定（`high-risk` → high, `feature` → medium, `bug` → low）

4. **Git ブランチ作成**
   
   **前提**: develop ブランチから作成
   
   すべての Risk Level で統一:
   
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/{FEATURE_ID}
   ```
   
   例: `git checkout -b feature/FEATURE-123`
   
   理由：単一ブランチで文書とコードを管理。Design Review と Implementation Review は PR のラベルで区別。

5. **ディレクトリ作成**
   ```bash
   mkdir -p sdlc/features/{FEATURE_ID}
   ```
   
   `.metadata` を作成：
   ```
   FEATURE_ID={FEATURE_ID}
   RISK_LEVEL={low|medium|high}
   STATUS=planning
   CREATED_DATE={YYYY-MM-DD}
   DECISION_STATUS=pending
   ISSUE_URL={Issue URL}
   BRANCH=feature/{FEATURE_ID}
   ```
   
   注：すべての Risk Level で `feature/{FEATURE_ID}` を使用

6. **テンプレート読取 & 文書生成**
   
   Risk Level に応じたテンプレートを `sdlc/templates/` から読取：
   - **Low**: `00_context.md`, `decisions.md`, `risks.md`
   - **Medium**: Low + `10_requirements.md`, `20_design.md`, `50_test_plan.md`
   - **High**: Medium + `60_release_plan.md`
   
   注：`30_implementation_plan.md` は Decision 確定後に `/sdlc-impl-plan` で生成
   
   **テンプレートのプレースホルダーを埋める**：
   - `{FEATURE_ID}` → Feature ID
   - `{ISSUE_LINK}` → Issue URL
   - `{DATE}` → 今日の日付 (YYYY-MM-DD)
   
   **テンプレート構造に従って Issue の内容をマッピング**：
   
   `00_context.md`:
   - Background: Issue の Why セクション
   - Problem Statement: Issue で解決すべき問題
   - Goals: Issue の What セクション
   - Non-Goals: Issue の Scope に記載された Out of Scope
   - Constraints: 技術的・ビジネス的制約（Issue から抽出）
   - Success Metrics: Acceptance Criteria を測定可能な形式に
   
   `decisions.md`:
   - Issue で不明確な点や選択肢がある部分を Decision として記載
   - 各 Decision の Status は **必ず PENDING** にする
   - Options を複数提示し、Pros/Cons を記載
   - Issue に How が記載されている場合も、それを Option A として提示（他の選択肢も検討）
   
   `risks.md`:
   - Issue の Risk Level セクションから抽出
   - 技術的リスク、データリスク、運用リスクを識別

7. **重要な原則**
   - **テンプレート構造を厳守**：勝手にセクションを追加しない（Assumptions, Open Questions など）
   - **Issue の範囲を厳守**：Issue に書かれていない機能を勝手に追加しない
   - **decisions.md の Status は必ず PENDING**：チームでの議論・承認が必要
   - **不明確な点は decisions.md に**：技術的選択肢や設計判断が必要なものは Decision として記載
   - **事実確認が必要な点は context に記載**：例えば「Stakeholders TBD」「Constraints 要確認」など

8. **ファイル書込**
   
   Write ツールで各ファイルに書き込む

9. **完了メッセージ**
   ```markdown
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

## エラー処理

- `gh` 未インストール → `brew install gh` または `gh auth login`
- Issue URL 無効 → 有効フォーマット表示
- Issue 取得失敗 → `gh auth status` 確認
- Feature 既存 → 削除するか別 ID 使用
