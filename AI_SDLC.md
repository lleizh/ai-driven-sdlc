# AI 駆動型 SDLC 開発プロセス

## 目的
AI を実行エンジンとして使い、開発を速くしつつ、
意思決定（Decision）とリスク（Risk）を明確にし、監査可能（auditable）にする。

## 基本原則（Core Principles）
1. Issue は唯一の入口（Single Entry Point）
2. SDLC 文書は repository で管理し、コードと同じく version 化する
3. Decision は人間が行い、AI はドラフトと実行を担う
4. 高リスクのみ設計 Review（軽量運用を維持）
5. 未記録リスクは未評価とみなす

---

## 全体フロー（Minimal）
1) Issue（Why/What/Risk）
2) SDLC 草稿（AI）
3) リスク判定
   - 低：Decision → 実装へ
   - 中/高：設計 Review → Decision → 実装へ
4) 実装（AI）
5) PR Review（必須）→ マージ

---

## アーティファクト（Artifacts）
### Feature ディレクトリ
sdlc/features/FEATURE-123/
- 00_context.md
- 10_requirements.md（中/高）
- 20_design.md（中/高）
- 30_implementation_plan.md（推奨：中/高。高は必須）
- 40_review_findings.md（PR 前チェック結果）
- 50_test_plan.md（中/高）
- 60_release_plan.md（高）
- decisions.md（PENDING/CONFIRMED/REVISED）
- risks.md

### “10分で理解”ルール（読み順）
Issue → decisions.md → risks.md → 20_design.md →（必要なら）他

---

## Review 方針（Two Reviews）
### A) 設計 Review（中/高のみ）
目的：盲点発見（投票ではない）
対象：Context / Design方向性 / Risks の3点のみ
アウトプット：Reviewコメント（必要なら 40_review_findings.md に要約）

### B) PR Review（全変更）
目的：決定どおりに実装されているか
注意：この段階で設計方針を再議論しない（議論は Decision Revision へ）

---

## Decision Gate（最重要）
- decisions.md に “CONFIRMED” が入ったら実装開始可能
- Decision は必ず以下を含む：
  - Topic / Chosen Option / Rejected Options
  - Rationale
  - Accepted Risks / Non-Negotiables
  - Decision Maker / Date

---

## 設計が外れた（Design drift）時の扱い
- 実装を止めて Decision レイヤーに戻る
- decisions.md に “REVISED” として追記（修正は正常運用）
- 修正後に implementation_plan を更新し、再開

---

## 三原則（Iron Rules）
1. Issue がなければコードを書かない
2. CONFIRMED な decisions.md がなければ実装しない
3. 記録されていないリスクは未評価とみなす

---

## コマンドの責任範囲（Command Responsibilities）

開発プロセスの各ステップを明確に分離：

| コマンド | 職責 | 失敗原因 | 修復方法 |
|---------|------|----------|---------|
| `/sdlc-init` | SDLC 文書の生成 | Issue 不正、GitHub 認証失敗 | Issue 修正、認証確認 |
| `/sdlc-decision` | Decision の確定 | 矛盾検出（Blocker） | Option 修正または文書更新 |
| `/sdlc-coding` | コード生成 | 論理エラー、構文エラー | コード修正 |
| `/sdlc-test` | 機能検証（テスト実行） | テスト失敗 | コード修正またはテスト修正 |
| `/sdlc-check` | 一致性検証 | Decision 違反、未記録リスク | コード修正または Decision Revision |
| `/sdlc-pr-code` | PR 作成 | - | - |

### /sdlc-test の特徴
- `50_test_plan.md` に記載されたテストコマンドを実行
- テスト結果をサマリー形式で表示（失敗したテストの詳細を含む）
- E2E テストの実行は `50_test_plan.md` の設定に従う
- テスト失敗時も正常終了し、結果をレポート（開発者が判断）
