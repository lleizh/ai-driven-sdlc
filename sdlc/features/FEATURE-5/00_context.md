# Context

**Feature ID**: FEATURE-5  
**Issue Link**: https://github.com/lleizh/ai-driven-sdlc/issues/5  
**Created**: 2025-12-26  
**Last Updated**: 2025-12-26

## Background
`./sdlc-cli report` コマンドを実行すると、以下のエラーが発生し、SDLC 管理レポートが表示できない状態が確認された：

```
./sdlc-cli: line 886: 0
0: syntax error in expression (error token is "0")
```

このエラーは Feature が存在しない環境で `report` コマンドを実行した際に発生する。SDLC管理ツールの基本機能であるレポート表示が、特定の状態で動作しないことはユーザビリティの観点から問題である。

## Problem Statement
sdlc-cli の `report` コマンドにおいて、Feature が存在しない（またはtotalが0の）状態で実行すると、除算エラーにより処理が失敗する。具体的には、958行目で `calc "$revision_count / $total"` を実行する際、`$total` が 0 のままとなり、除算エラー（division by zero）が発生する。

現在の条件判定は `[[ $revision_count -gt 0 ]]` のみで、分母となる `$total` のゼロチェックが不足している。

## Goals
- Feature が存在しない状態でも `./sdlc-cli report` コマンドがエラーなく実行できるようにする
- 除算エラーを防ぐための適切な条件判定を追加する
- エッジケース（Feature 0件）に対する堅牢性を向上させる

## Non-Goals
- レポート表示内容の機能拡張
- 他のsdlc-cliコマンドの修正
- パフォーマンスの最適化

## Stakeholders
| Role | Name | Responsibility |
|------|------|----------------|
| Product Owner | TBD | 要件承認 |
| Tech Lead | TBD | 技術レビュー |
| Reviewer | TBD | コードレビュー |

## Constraints
- 既存機能への影響を最小限にする（後方互換性維持）
- 1行の条件追加のみで対応可能（シンプルな修正）
- 他の部分のリファクタリングは行わない

## Success Metrics
- Feature が存在しない状態で `./sdlc-cli report` を実行してもエラーが発生しない
- Feature が存在する場合、従来通り平均 Revision が正しく計算・表示される
- `$total = 0` の場合、平均 Revision の計算・表示がスキップされる

## References
- Issue: https://github.com/lleizh/ai-driven-sdlc/issues/5
- エラー発生箇所: `sdlc-cli:958`
