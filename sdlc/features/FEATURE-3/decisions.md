# Decisions

**Feature ID**: FEATURE-3  
**Last Updated**: 2025-12-26

---

## Decision 1: Label 初期化の実行タイミング

**Status**: PENDING  
**Date**: 2025-12-26  
**Decision Maker**: TBD

### Context
`install.sh` スクリプト内で Label 初期化を実行するタイミングを決定する必要がある。ユーザーが明示的に実行するか、自動的に実行するかで、ユーザー体験と制御性のトレードオフがある。

### Options Considered

#### Option A: install.sh の最後に自動実行（Issue 提案）
**Pros**:
- セットアップが完全に自動化される
- ユーザーが Label 作成を忘れることがない
- エラー発生を未然に防げる

**Cons**:
- ユーザーが意図しないタイミングで Label が作成される可能性
- GitHub 認証エラー時にインストール全体が失敗したように見える（実際はスキップ）

**Cost/Effort**: 低

#### Option B: 別コマンドとして提供（`./install.sh --init-labels`）
**Pros**:
- ユーザーが明示的に実行できる
- インストール処理と分離される
- GitHub 認証問題がインストール本体に影響しない

**Cons**:
- ユーザーが Label 初期化を忘れる可能性
- エラー発生時に追加の手順が必要
- ドキュメントに追加手順の記載が必要

**Cost/Effort**: 低

#### Option C: 初回コマンド実行時に自動チェック・作成
**Pros**:
- 本当に必要なタイミングで実行される
- インストール処理と完全に分離される

**Cons**:
- すべての SDLC コマンドに Label チェック処理を追加する必要がある
- 実装コストが高い
- コマンド実行時のレイテンシが増加

**Cost/Effort**: 高

### Decision
**Chosen Option**: TBD

**Rationale**:
チームで議論して決定してください。Issue では Option A が提案されていますが、他の選択肢も検討する価値があります。

**Accepted Risks**:
- TBD

**Non-Negotiables**:
- `gh` コマンドが存在しない場合、処理を中断せずスキップすること
- GitHub 認証エラーの場合、処理を中断せずスキップすること
- 既存 Label を重複作成しないこと（冪等性）

### Impact
- **Technical**: install.sh スクリプトに新しい関数を追加
- **Team**: セットアップ手順の変更なし（自動実行の場合）
- **Timeline**: 実装は 1-2 時間程度
- **Cost**: なし

### Follow-up Actions
- [ ] Option を決定する
- [ ] エラーメッセージの文言を確認する
- [ ] テストケースを定義する

---

## Decision 2: エラーハンドリングの詳細度

**Status**: PENDING  
**Date**: 2025-12-26  
**Decision Maker**: TBD

### Context
Label 作成時にエラーが発生した場合（`gh` コマンド不在、認証エラー、一部 Label 作成失敗など）、どの程度詳細なエラーメッセージを表示するかを決定する必要がある。

### Options Considered

#### Option A: シンプルな警告メッセージ（Issue 提案）
**Pros**:
- ユーザーに過度な情報を提示しない
- インストール処理の流れを中断しない
- 初心者にも理解しやすい

**Cons**:
- トラブルシューティングが難しい場合がある
- 詳細なエラー情報が必要な場合、追加調査が必要

**Cost/Effort**: 低

#### Option B: 詳細なエラーメッセージとトラブルシューティング手順
**Pros**:
- ユーザーが自分で問題を解決しやすい
- サポート負荷が減る
- 上級ユーザーにとって有用

**Cons**:
- 初心者には情報過多になる可能性
- エラーメッセージが長くなる
- 実装コストが高い

**Cost/Effort**: 中

#### Option C: エラーレベル別のメッセージ（警告 vs エラー）
**Pros**:
- 致命的なエラーと警告を区別できる
- ユーザーが重要度を判断しやすい

**Cons**:
- 実装が複雑になる
- エラーレベルの定義が必要

**Cost/Effort**: 中

### Decision
**Chosen Option**: TBD

**Rationale**:
チームで議論して決定してください。Issue では Option A が暗黙的に提案されていますが、ユーザー体験を考慮して選択してください。

**Accepted Risks**:
- TBD

**Non-Negotiables**:
- エラーが発生してもインストール処理全体を中断しないこと
- ユーザーに対して次のアクションを明示すること

### Impact
- **Technical**: エラーメッセージの文言とフォーマット
- **Team**: サポート負荷に影響する可能性
- **Timeline**: 実装は 30分-1時間程度
- **Cost**: なし

### Follow-up Actions
- [ ] Option を決定する
- [ ] エラーメッセージの文言を作成する

---

## Decision 3: Label の色と説明のカスタマイズ可否

**Status**: PENDING  
**Date**: 2025-12-26  
**Decision Maker**: TBD

### Context
Issue では特定の色とデフォルト説明が提案されているが、ユーザーがこれらをカスタマイズできるようにするかを決定する必要がある。

### Options Considered

#### Option A: 固定の色と説明（Issue 提案）
**Pros**:
- 実装がシンプル
- すべてのリポジトリで一貫性が保たれる
- メンテナンスが容易

**Cons**:
- ユーザーの既存 Label 体系と衝突する可能性
- カスタマイズできない

**Cost/Effort**: 低

#### Option B: 設定ファイルでカスタマイズ可能
**Pros**:
- ユーザーが色や説明を変更できる
- 既存の Label 体系に合わせられる
- 柔軟性が高い

**Cons**:
- 実装コストが高い
- 設定ファイルのメンテナンスが必要
- 複雑度が増す

**Cost/Effort**: 高

#### Option C: コマンドライン引数でカスタマイズ
**Pros**:
- 設定ファイル不要
- 一時的なカスタマイズが可能

**Cons**:
- 引数が多くなる
- ユーザーが毎回指定する必要がある
- 実装コストが中程度

**Cost/Effort**: 中

### Decision
**Chosen Option**: TBD

**Rationale**:
チームで議論して決定してください。最初のバージョンでは Option A（固定）を選択し、将来的に Option B を検討する方針も妥当です。

**Accepted Risks**:
- TBD

**Non-Negotiables**:
- Label 名は変更不可（SDLC コマンドがこれらの名前に依存しているため）

### Impact
- **Technical**: 実装の複雑度が Option によって変わる
- **Team**: カスタマイズ可能にする場合、ドキュメントが必要
- **Timeline**: Option A: 30分、Option B: 2-3時間、Option C: 1-2時間
- **Cost**: なし

### Follow-up Actions
- [ ] Option を決定する
- [ ] 将来的なカスタマイズ機能の必要性を評価する

---

## Quick Reference

### All Confirmed Decisions
（まだ確定した Decision はありません）

### Pending Decisions
1. **Label 初期化の実行タイミング**: Option A/B/C を選択 - TBD
2. **エラーハンドリングの詳細度**: Option A/B/C を選択 - TBD
3. **Label の色と説明のカスタマイズ可否**: Option A/B/C を選択 - TBD

---

## Notes
- Issue では Option A（自動実行、シンプルなエラーメッセージ、固定の色と説明）が提案されていますが、他の選択肢も検討する価値があります
- チームで議論して、ユーザー体験と実装コストのバランスを考慮してください
