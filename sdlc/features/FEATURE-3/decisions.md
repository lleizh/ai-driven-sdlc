# Decisions

**Feature ID**: FEATURE-3  
**Last Updated**: 2025-12-26

---

## Decision 1: Label 初期化の実行タイミング

**Status**: CONFIRMED  
**Date**: 2025-12-26  
**Decision Maker**: AI Agent (based on Issue recommendation)

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
**Chosen Option**: Option A (install.sh の最後に自動実行)

**Rationale**:
Issue で提案されている Option A を採用します。理由：
1. ユーザー体験の向上：セットアップが完全に自動化され、Label 作成を忘れることがない
2. エラー防止：SDLC コマンド実行時の "label not found" エラーを未然に防げる
3. 実装コスト：低コストで実現可能
4. エラーハンドリング：`gh` コマンド不在や認証エラーの場合は警告を表示してスキップするため、インストール全体には影響しない

**Accepted Risks**:
- GitHub 認証エラー時にユーザーが混乱する可能性（低リスク）→ 明確な警告メッセージで軽減
- ユーザーが意図しないタイミングで Label が作成される可能性（低リスク）→ 冪等性を保証することで安全性を確保

**Non-Negotiables**:
- `gh` コマンドが存在しない場合、処理を中断せずスキップすること
- GitHub 認証エラーの場合、処理を中断せずスキップすること
- 既存 Label を重複作成しないこと（冪等性）

### Impact
- **Technical**: install.sh スクリプトに新しい関数 `initialize_labels()` を追加
- **Team**: セットアップ手順の変更なし（自動実行）
- **Timeline**: 実装は 1-2 時間程度
- **Cost**: なし

### Follow-up Actions
- [x] Option を決定する
- [ ] エラーメッセージの文言を確認する
- [ ] テストケースを定義する

---

## Decision 2: エラーハンドリングの詳細度

**Status**: CONFIRMED  
**Date**: 2025-12-26  
**Decision Maker**: AI Agent (based on Issue recommendation)

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
**Chosen Option**: Option A (シンプルな警告メッセージ)

**Rationale**:
Issue で暗黙的に提案されている Option A を採用します。理由：
1. ユーザー体験：初心者にも理解しやすく、インストール処理の流れを中断しない
2. 実装コスト：低コストで実現可能
3. 十分な情報提供：警告メッセージに次のアクションを明示することで、ユーザーは問題を認識して対応できる
4. Issue のコード例：Issue に記載されたコード例はシンプルな警告メッセージを想定している

**Accepted Risks**:
- トラブルシューティングが難しい場合がある（低リスク）→ README に詳細な前提条件と手順を記載することで軽減

**Non-Negotiables**:
- エラーが発生してもインストール処理全体を中断しないこと
- ユーザーに対して次のアクションを明示すること

### Impact
- **Technical**: エラーメッセージの文言とフォーマット（シンプルな警告文）
- **Team**: サポート負荷は最小限（README で対応）
- **Timeline**: 実装は 30分-1時間程度
- **Cost**: なし

### Follow-up Actions
- [x] Option を決定する
- [ ] エラーメッセージの文言を作成する

---

## Decision 3: Label の色と説明のカスタマイズ可否

**Status**: CONFIRMED  
**Date**: 2025-12-26  
**Decision Maker**: AI Agent (based on Issue recommendation)

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
**Chosen Option**: Option A (固定の色と説明)

**Rationale**:
Issue で提案されている Option A を採用します。理由：
1. 実装コスト：シンプルで低コスト、メンテナンスが容易
2. 一貫性：すべてのリポジトリで Label の色と説明が一貫する
3. 冪等性：既存 Label はスキップするため、既存の Label 体系には影響しない
4. 将来の拡張性：必要に応じて将来的に Option B（設定ファイル）を追加可能
5. Issue の明確な提案：Issue に具体的な色コードと説明が記載されている

**Accepted Risks**:
- 既存 Label との色や説明の不一致（低リスク）→ SDLC コマンドは Label 名のみを参照するため機能的には問題なし
- カスタマイズできない（低リスク）→ 将来的な拡張で対応可能

**Non-Negotiables**:
- Label 名は変更不可（SDLC コマンドがこれらの名前に依存しているため）
- 既存 Label は重複作成しないこと（スキップする）

### Impact
- **Technical**: 実装がシンプル（固定の色と説明を配列で定義）
- **Team**: ドキュメント不要（README の変更なし）
- **Timeline**: 実装は 30分程度
- **Cost**: なし

### Follow-up Actions
- [x] Option を決定する
- [ ] 将来的なカスタマイズ機能の必要性を評価する（フィードバック次第）

---

## Quick Reference

### All Confirmed Decisions
1. **Label 初期化の実行タイミング**: Option A (install.sh の最後に自動実行) - 2025-12-26
2. **エラーハンドリングの詳細度**: Option A (シンプルな警告メッセージ) - 2025-12-26
3. **Label の色と説明のカスタマイズ可否**: Option A (固定の色と説明) - 2025-12-26

### Pending Decisions
（すべて確定しました）

---

## Notes
- 3つの Decision すべてで Option A を採用
- Issue の提案に従い、実装コストを最小化しつつユーザー体験を向上
- 将来的な拡張性は維持（必要に応じてカスタマイズ機能を追加可能）
