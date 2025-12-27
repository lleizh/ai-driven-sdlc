# FEATURE-20: Unify GitHub Projects Status field - remove custom SDLC Status

## 概要

GitHub Projects の Status フィールドを統一し、カスタムフィールド「SDLC Status」を削除することで、ユーザーの混乱を減らし、シンプルで直感的なワークフローを実現する。

## 背景

現在、GitHub Projects では以下の2つの Status フィールドが存在している：

1. **デフォルトの Status フィールド**
   - GitHub Projects が自動的に提供
   - 標準的な状態管理に使用

2. **カスタムフィールド「SDLC Status」**
   - プロジェクト固有のカスタムフィールド
   - 独自の SDLC ステータスを管理するために作成

この2つのフィールドが共存することで、以下の問題が発生している：

- どちらのフィールドを使用すべきか混乱する
- 2つのフィールドで異なる値が設定される可能性がある
- ワークフロー自動化が複雑になる
- 新規参加者にとって理解しにくい

## 目的

1. Status フィールドを1つに統一
2. デフォルトの Status フィールドのみを使用
3. カスタムフィールド「SDLC Status」を削除
4. ワークフロー自動化を簡素化
5. プロジェクト管理の複雑さを軽減

## スコープ

### 対象

- GitHub Projects の Status フィールド設定
- `.github/workflows/sync-metadata-to-project.yml` の更新
- カスタムフィールド「SDLC Status」の削除
- 既存の Issue/PR の Status 移行
- `sdlc-cli sync` コマンドの追加
  - `sdlc/features/` 配下の全 feature を GitHub Projects に同期
  - Feature ID でマッチング、存在しない場合は追加
  - Issue URL がない feature はスキップ

### 対象外

- 他のカスタムフィールドの変更
- プロジェクトボード以外の GitHub 設定
- SDLC プロセス自体の変更

## 制約条件

- 既存の Issue/PR のステータスを保持する必要がある
- ワークフロー自動化が正常に動作し続ける必要がある
- GitHub Projects API の制限に従う必要がある

## 成功基準

1. カスタムフィールド「SDLC Status」が削除されている
2. すべての自動化がデフォルトの Status フィールドを使用している
3. 既存の Issue/PR のステータスが正しく移行されている
4. ワークフロー自動化が正常に動作している
5. ドキュメントが更新されている

## 関連リソース

- Issue: https://github.com/lleizh/ai-driven-sdlc/issues/20
- Workflow: `.github/workflows/sync-metadata-to-project.yml`
- SDLC Metadata: `sdlc/features/*//.metadata`
