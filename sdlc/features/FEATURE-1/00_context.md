# Context

**Feature ID**: FEATURE-1  
**Issue Link**: https://github.com/lleizh/ai-driven-sdlc/issues/1  
**Created**: 2025-12-26  
**Last Updated**: 2025-12-26

## Background

README.md と install.sh の一致性調査の結果、以下の不整合が判明：
1. install.sh に不要なオプション（`--minimal`, `--no-templates`）が実装されている
2. 重要なオプション（`--force`, `--update`）が README.md に文書化されていない
3. README.md のコマンド一覧に `/sdlc-issue` と `/sdlc-coding` が欠落している

ドキュメントと実装の一致性を保ち、ユーザーに正確な情報を提供する必要がある。

## Problem Statement

現在、ドキュメント（README.md）と実装（install.sh）の間に不整合が存在し、ユーザーに誤った情報を提供している。
また、有用なオプション（`--force`, `--update`）が文書化されていないため、ユーザーがこれらの機能を利用できない。

## Goals

1. install.sh から不要なオプションを削除し、実装をシンプルにする
2. README.md に実際に使用可能なオプションを正確に記載する
3. README.md のコマンド一覧を完全にし、すべての利用可能なコマンドを文書化する

## Non-Goals

- install.sh の機能追加（削除のみ）
- README.md の大幅な構造変更
- 他のドキュメントファイルの更新

## Stakeholders

| Role | Name | Responsibility |
|------|------|----------------|
| Product Owner | TBD | 変更の承認 |
| Tech Lead | TBD | 実装レビュー |
| Reviewer | TBD | ドキュメントレビュー |

## Constraints

- 既存の install.sh ユーザーへの影響を最小限に（削除するのは不要な機能のみ）
- README.md の全体的な構造とトーンを維持
- 2ファイルのみの変更に制限

## Success Metrics

- install.sh と README.md の記載が100%一致する
- 削除したオプションに関するエラー報告がない（そもそも使用されていないことを確認）
- ユーザーが `--force` と `--update` オプションを発見し使用できる

## References

- 一致性調査の結果：実装の質は非常に高い（98/100）
- install.sh v1.0.0
- sdlc-cli v2.0.1
