# Decisions（決定事項）

**Feature ID**: FEATURE-45  
**Last Updated**: 2026-01-09

---

## Decision 1: パイプ実行時の確認処理の実装方法

**Status**: CONFIRMED  
**Date**（日付）: 2026-01-09  
**Decision Maker**（意思決定者）: AI Agent (approved by user)

### Context（背景）

現在の `read -p` による確認処理は、パイプ実行時に stdin がパイプに占有されているため動作しません。パイプ実行（`curl | bash`）は推奨インストール方法として文書化されているため、この問題を解決する必要があります。

### Options Considered（検討した選択肢）

#### Option A: /dev/tty を使用
**Pros**（長所）:
- パイプ実行時でもキーボード入力を直接読み取れる
- 対話型の確認プロセスを維持できる

**Cons**（短所）:
- `/dev/tty` が存在しない環境（CI/CD）で失敗する可能性
- 追加の条件分岐が必要

**Cost/Effort**（コスト・工数）: 低（条件分岐の追加のみ）

**Rejection Reason**: CI/CD 環境での互換性に懸念があり、Option B の方がシンプルで堅牢

#### Option B: 非対話モードを自動検出して続行（推奨）✅
**Pros**（長所）:
- `[[ -t 0 ]]` による標準的な bash パターン
- CI/CD 環境でも動作する
- シンプルで保守性が高い
- パイプ実行時の UX が向上（確認不要）

**Cons**（短所）:
- パイプ実行時に確認をスキップする（セキュリティ上の懸念は低い）

**Cost/Effort**（コスト・工数）: 低（if 文1つの修正）

#### Option C: --yes フラグを追加
**Pros**（長所）:
- 明示的な確認スキップ
- 自動化スクリプトでの使用が容易
- 対話型の確認を維持

**Cons**（短所）:
- 引数パースの追加が必要
- パイプ実行時のデフォルト動作が不明確
- Option B との組み合わせが必要

**Cost/Effort**（コスト・工数）: 中（引数パース実装が必要）

**Rejection Reason**: Option B で十分な機能を提供でき、追加の複雑さが不要

### Decision（決定）
**Chosen Option**（選択した選択肢）: Option B - 非対話モードを自動検出して続行

**Rationale**（理由）:
- `[[ -t 0 ]]` は bash の標準的なパターンであり、広く使用されている
- パイプ実行と対話実行の両方をシンプルな条件分岐で処理できる
- CI/CD 環境での互換性が最も高い
- インストールスクリプトの確認プロンプトはセキュリティ上の必須要件ではなく、UX 向上のための機能
- 非対話モードで続行する旨のメッセージを表示することで透明性を確保

**Accepted Risks**（受け入れたリスク）:
- 特定の環境（リダイレクトされた stdin）で誤検出の可能性（risks.md の R002 で記録済み、発生確率 Low）
- パイプ実行時に確認をスキップすることによる意図しないインストール（リスクは低い）

**Non-Negotiables**（譲れない点）:
- `curl | bash` でのインストールが動作すること
- 既存の対話型インストール（`bash install.sh`）が引き続き動作すること

### Impact（影響）
- **Technical**（技術的）: install.sh の Lines 146-151 の確認処理ロジックを修正
- **Team**（チーム）: なし
- **Timeline**（タイムライン）: 実装時間 < 1時間
- **Cost**（コスト）: なし

### Follow-up Actions（フォローアップアクション）
- [ ] Option B を install.sh に実装
- [ ] パイプ実行と対話実行の両方でテスト
- [ ] 非対話モードで続行する際のメッセージを追加

---

## Decision 2: GitHub Owner ID 取得の GraphQL クエリ方法

**Status**: CONFIRMED  
**Date**（日付）: 2026-01-09  
**Decision Maker**（意思決定者）: AI Agent (approved by user)

### Context（背景）

現在の実装は `user` クエリのみを使用しており、Organization リポジトリで失敗します。さらに、エラー時の JSON レスポンスが `$OWNER_ID` に格納され、バリデーションをパスしてしまう問題があります。

### Options Considered（検討した選択肢）

#### Option A: repositoryOwner を使用（推奨）✅
**Pros**（長所）:
- User と Organization の両方をサポートする union type
- コードの簡素化（owner type の判定不要）
- GitHub API の推奨パターン

**Cons**（短所）:
- なし

**Cost/Effort**（コスト・工数）: 低（クエリの文字列変更のみ）

#### Option B: user と organization を個別にクエリ
**Pros**（長所）:
- owner type を明示的に判定できる

**Cons**（短所）:
- 2回の API 呼び出しが必要（遅延）
- コードが複雑化
- repositoryOwner で同じことが実現可能

**Cost/Effort**（コスト・工数）: 中（分岐処理とエラーハンドリングが必要）

**Rejection Reason**: repositoryOwner で同等の機能を実現でき、より簡潔

#### Option C: エラーレスポンスのバリデーション強化のみ
**Pros**（長所）:
- 最小限の変更

**Cons**（短所）:
- Organization リポジトリの問題が解決しない
- 根本的な解決にならない

**Cost/Effort**（コスト・工数）: 低

**Rejection Reason**: 根本的な問題（Organization サポート）が解決しない

### Decision（決定）
**Chosen Option**（選択した選択肢）: Option A - repositoryOwner を使用

**Rationale**（理由）:
- `repositoryOwner` は GitHub GraphQL API の union type であり、User と Organization の両方を返す
- GitHub の公式ドキュメントで推奨されているパターン
- クエリ文字列を `user` から `repositoryOwner` に変更するだけで実装完了
- owner type の判定分岐が不要になり、コードがシンプルになる
- エラーハンドリングの改善（JSON エラーレスポンスの検出）も同時に実施

**Accepted Risks**（受け入れたリスク）:
- Organization での権限不足によるエラー（risks.md の R003 で記録済み、適切なエラーメッセージで対応）

**Non-Negotiables**（譲れない点）:
- 個人リポジトリで GitHub Project が作成できること
- Organization リポジトリで GitHub Project が作成できること
- エラーレスポンスが適切に検出され、無効な ID で API 呼び出しが行われないこと

### Impact（影響）
- **Technical**（技術的）: install.sh の Lines 366-373 の GraphQL クエリとバリデーションロジックを修正
- **Team**（チーム）: なし
- **Timeline**（タイムライン）: 実装時間 < 1時間
- **Cost**（コスト）: なし

### Follow-up Actions（フォローアップアクション）
- [ ] repositoryOwner クエリを install.sh に実装
- [ ] エラーレスポンスの検出ロジックを強化（`null` や `{` で始まる文字列のチェック）
- [ ] 個人リポジトリと Organization リポジトリの両方でテスト
- [ ] エラーハンドリングのテスト（無効な owner 名、権限不足など）

---

## Decision 3: macOS sed 互換性の解決方法

**Status**: CONFIRMED  
**Date**（日付）: 2026-01-09  
**Decision Maker**（意思決定者）: AI Agent (approved by user)

### Context（背景）

現在の sed コマンドは GNU sed の正規表現構文を使用しており、macOS の BSD sed では「RE error: parentheses not balanced」エラーが発生します。

### Options Considered（検討した選択肢）

#### Option A: より互換性のある正規表現を使用（推奨）✅
**Pros**（長所）:
- GNU sed と BSD sed の両方で動作
- 追加の依存関係不要
- シンプルな修正（デリミタを `/` から `#` に変更、エスケープを調整）

**Cons**（短所）:
- なし

**Cost/Effort**（コスト・工数）: 低（正規表現の修正のみ）

#### Option B: gsed を必須にする
**Pros**（長所）:
- GNU sed の全機能が使用可能

**Cons**（短所）:
- macOS ユーザーに追加のインストールが必要（`brew install gnu-sed`）
- インストールスクリプトが依存関係を持つことになる
- UX が悪化

**Cost/Effort**（コスト・工数）: 中（依存関係チェックと指示が必要）

**Rejection Reason**: インストールスクリプトに依存関係を持たせるべきではない

#### Option C: Perl を使用
**Pros**（長所）:
- より強力な正規表現
- macOS にプリインストール済み

**Cons**（短所）:
- sed を使用している他の部分との一貫性がない
- 過剰な解決策

**Cost/Effort**（コスト・工数）: 低

**Rejection Reason**: sed で十分に解決可能であり、過剰

### Decision（決定）
**Chosen Option**（選択した選択肢）: Option A - より互換性のある正規表現を使用

**Rationale**（理由）:
- GNU sed と BSD sed の両方で動作する正規表現パターンが存在する
- デリミタを `/` から `#` に変更することで、パス区切り文字のエスケープが不要になる
- バックスラッシュのエスケープを調整することで、BSD sed の構文エラーを回避
- 追加の依存関係やツールの変更が不要
- インストールスクリプトはシンプルさが重要

**Accepted Risks**（受け入れたリスク）:
- なし（この修正は既知の互換性パターンを使用）

**Non-Negotiables**（譲れない点）:
- macOS (BSD sed) でリポジトリ URL のパースが正常に動作すること
- 追加の依存関係を導入しないこと

### Impact（影響）
- **Technical**（技術的）: install.sh の Around line 297 のリポジトリ URL パース処理を修正
- **Team**（チーム）: なし
- **Timeline**（タイムライン）: 実装時間 < 30分
- **Cost**（コスト）: なし

### Follow-up Actions（フォローアップアクション）
- [ ] 互換性のある正規表現を install.sh に実装
- [ ] macOS (BSD sed) と Linux (GNU sed) の両方でテスト
- [ ] 各種リポジトリ URL フォーマットでテスト（HTTPS, SSH, git@, https://）

---

## Decision 4: --yes フラグの実装

**Status**: CONFIRMED  
**Date**（日付）: 2026-01-09  
**Decision Maker**（意思決定者）: AI Agent (approved by user)

### Context（背景）

Issue では `--yes` フラグの追加がオプション機能として提案されています。自動化スクリプトでの使用を容易にする目的です。

### Options Considered（検討した選択肢）

#### Option A: 実装する
**Pros**（長所）:
- CI/CD や自動化スクリプトでの使用が明示的
- `curl | bash -s -- --yes` のような使用方法

**Cons**（短所）:
- Decision 1 で Option B（非対話モード自動検出）を選択した場合、冗長になる可能性
- 引数パース処理の追加が必要

**Cost/Effort**（コスト・工数）: 中（引数パース実装が必要）

**Rejection Reason**: Decision 1 で非対話モード自動検出を採用したため、冗長

#### Option B: 実装しない（Decision 1 で非対話モード検出を採用する場合）✅
**Pros**（長所）:
- シンプル
- パイプ実行で自動的に続行される

**Cons**（短所）:
- 明示的な確認スキップができない

**Cost/Effort**（コスト・工数）: なし

### Decision（決定）
**Chosen Option**（選択した選択肢）: Option B - 実装しない

**Rationale**（理由）:
- Decision 1 で非対話モードの自動検出を採用したため、`--yes` フラグは不要
- パイプ実行時は自動的に続行されるため、明示的なフラグは冗長
- インストールスクリプトをシンプルに保つことが重要
- 将来的に必要になった場合、後から追加することも可能（後方互換性を保ちながら）

**Accepted Risks**（受け入れたリスク）:
- なし

**Non-Negotiables**（譲れない点）:
- Decision 1 の実装方針と整合性があること

### Impact（影響）
- **Technical**（技術的）: なし（実装しないため）
- **Team**（チーム）: なし
- **Timeline**（タイムライン）: なし
- **Cost**（コスト）: なし

### Follow-up Actions（フォローアップアクション）
- [ ] なし（実装しないため）

---

## Decision Summary（決定サマリー）

| Decision | Chosen Option | Status |
|----------|--------------|--------|
| 1. パイプ実行時の確認処理 | Option B: 非対話モード自動検出 | CONFIRMED |
| 2. GitHub Owner ID 取得 | Option A: repositoryOwner 使用 | CONFIRMED |
| 3. macOS sed 互換性 | Option A: 互換性のある正規表現 | CONFIRMED |
| 4. --yes フラグ | Option B: 実装しない | CONFIRMED |

**Overall Decision Date**: 2026-01-09  
**Decision Maker**: AI Agent (approved by user)

---

## Decision History（決定履歴）

### Revisions（改訂）

（まだ改訂はありません）
