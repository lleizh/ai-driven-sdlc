# Context

**Feature ID**: FEATURE-10  
**Issue Link**: https://github.com/lleizh/ai-driven-sdlc/issues/10  
**Created**: 2025-12-26  
**Last Updated**: 2025-12-26

## Background
現在の SDLC ワークフローでは、テストの実行タイミングと責任範囲が不明確です：

- `/sdlc-coding` は実装を行うが、テストを実行するかどうかが曖昧
- `/sdlc-check` は静的な一致性チェックだが、テストは含まれていない
- `50_test_plan.md` という独立したドキュメントがあるにもかかわらず、それを実行する専用コマンドが存在しない

この結果：
- テストが実行されないまま PR が作成される可能性がある
- テスト結果の監査証跡が不明確
- テストの再実行が困難（コード生成から再実行する必要がある）

## Problem Statement
SDLC ワークフローにおいて、テスト実行のステップが明確に定義されていないため、テストの実行が不確実で監査証跡が残らず、再実行も困難な状況になっている。

## Goals
- テスト実行のタイミングを明確化する
- テスト結果の監査証跡を残す
- テストの再実行を容易にする
- CI/CD との統合を容易にする

## Non-Goals
- CI/CD パイプラインの自動化実装
- テストフレームワークの変更
- 既存コマンド（`/sdlc-coding`, `/sdlc-check`, `/sdlc-pr-code`）の動作変更

## Stakeholders
| Role | Name | Responsibility |
|------|------|----------------|
| Product Owner | TBD | 機能要件の承認 |
| Tech Lead | TBD | 技術的実装の承認 |
| Reviewer | TBD | コードレビュー |

## Constraints
- 既存のコマンド（`/sdlc-coding`, `/sdlc-check`, `/sdlc-pr-code`）には一切変更を加えない
- 既存ワークフローを破壊しない
- `50_test_plan.md` で定義されたテスト構造に従う
- bash スクリプトまたは既存 CLI ツールの呼び出しで実装する

## Success Metrics
- `/sdlc-test <feature-id>` コマンドが正常に実行され、テスト結果が明確に表示される
- テスト失敗時に適切なエラーメッセージが表示される
- 開発者が `/sdlc-test` を使用して、コード修正後のテスト再実行を容易に行える
- `/sdlc-coding` の完了メッセージに次のステップとして `/sdlc-test` が記載される

## References
- FEATURE-7 の実装経験
- 業界標準：npm (build/test/lint), make (make/test/check), cargo (build/test/clippy), go (build/test/vet)
- `50_test_plan.md` テンプレート
