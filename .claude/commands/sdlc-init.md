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

4. **ディレクトリ作成**
   ```bash
   mkdir -p sdlc/features/{FEATURE_ID}
   ```
   
   `.metadata` を作成：
   ```
   FEATURE_ID={FEATURE_ID}
   RISK_LEVEL={low|medium|high}
   STATUS=draft
   CREATED_DATE={YYYY-MM-DD}
   DECISION_STATUS=pending
   ISSUE_URL={Issue URL}
   ```

5. **テンプレート読取 & 文書生成**
   
   Risk Level に応じたテンプレートを読取：
   - **Low**: `00_context.md`, `decisions.md`, `risks.md`
   - **Medium**: Low + `10_requirements.md`, `20_design.md`, `50_test_plan.md`
   - **High**: Medium + `60_release_plan.md`
   
   注：`30_implementation_plan.md` は Decision 確定後に `/sdlc-impl-plan` で生成
   
   Issue の内容でテンプレートのプレースホルダーを埋める：
   - `{FEATURE_ID}` → Feature ID
   - `{ISSUE_LINK}` → Issue URL
   - `{DATE}` → 今日の日付
   - Issue の Why/What/How/Risk から各セクションを埋める

6. **重要な原則**
   - Issue に明記されていない情報 → **Assumptions** に記載
   - 不明確な点 → **Open Questions** に記載
   - **decisions.md の Status は必ず PENDING にする**
   - Issue の範囲を厳守（勝手に拡張しない）

7. **ファイル書込**
   
   Write ツールで各ファイルに書き込む

8. **完了メッセージ**
   ```markdown
   ✅ SDLC 文書を生成しました
   
   📋 生成情報:
   - Issue: {URL}
   - Feature ID: {ID}
   - Risk Level: {level}
   - 生成ファイル数: {数}
   
   ⚠️ 重要:
   - Assumptions と Open Questions を確認してください
   - decisions.md は PENDING です（チームで確定が必要）
   - Issue の範囲を超えていないか確認してください
   ```

**重要**: メッセージ表示後、停止。追加の提案や実装コードは生成しない。

---

## エラー処理

- `gh` 未インストール → `brew install gh` または `gh auth login`
- Issue URL 無効 → 有効フォーマット表示
- Issue 取得失敗 → `gh auth status` 確認
- Feature 既存 → 削除するか別 ID 使用
