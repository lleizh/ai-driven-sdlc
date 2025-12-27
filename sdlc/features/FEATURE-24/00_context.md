# Context（文脈）

**Feature ID**: FEATURE-24  
**Issue Link**: https://github.com/lleizh/ai-driven-sdlc/issues/24  
**Created**: 2025-12-27  
**Last Updated**: 2025-12-27

## Background（背景）

現在の SDLC フローでは、`/sdlc-init` を実行して `.metadata` ファイルを作成するまで、Issue が GitHub Projects に追加されません。

**問題点：**
- 新規 Issue が Projects に表示されない
- PM/管理層が Issue の全体像を把握しづらい
- `/sdlc-init` 実行前の Issue は SDLC 管理対象外

**期待する改善：**
- Issue 作成時点で GitHub Projects に表示
- ラベルベースで柔軟に管理
- `/sdlc-init` 後は完全な Feature として管理

## Problem Statement（課題）

PM や管理層が新規 Issue を GitHub Projects で把握できず、SDLC フロー全体の可視性が低い。Issue が `/sdlc-init` を実行するまで Projects に表示されないため、初期段階の Issue 管理が困難。

## Goals（目標）

- Issue にラベルを追加することで、自動的に GitHub Projects に追加する機能を実装
- ラベル削除時に、`.metadata` の有無に基づいて智能的に Projects から削除または保持
- 既存の SDLC フロー（`/sdlc-init`, `sync-projects.yml`）との互換性を保つ
- PM/管理層が Issue 作成時点から全体像を把握できるようにする

## Non-Goals（非目標）

- 既存の `/sdlc-init` コマンドの動作変更
- `sync-projects.yml` の既存機能の変更
- Issue 本体の構造変更
- Projects の手動操作の完全禁止（只読化は推奨だが必須ではない）

## Stakeholders（関係者）

| 役割 | 名前 | 責任 |
|------|------|------|
| Product Owner | TBD | 機能の承認と優先度決定 |
| Tech Lead | TBD | 技術的アーキテクチャの承認 |
| Reviewer | TBD | コードレビューと設計レビュー |

## Constraints（制約）

- GitHub Actions の API レート制限を考慮する必要がある
- `secrets.GH_PAT` が必要（Projects v2 API アクセス用）
- 既存の `sync-projects.yml` との競合を避ける必要がある
- `.metadata` ファイルの存在確認のために repository checkout が必要
- ロールバック可能な設計（workflow ファイルを削除すれば元に戻る）

## Success Metrics（成功指標）

- Issue に `sdlc:track` ラベルを追加すると、自動的に GitHub Projects に追加される
- 既に Projects にある Issue に再度ラベルを追加しても、重複しない
- `/sdlc-init` を実行していない Issue からラベルを削除すると、Projects から削除される
- `/sdlc-init` を実行済みの Feature からラベルを削除しても、Projects に保持される
- 新規 workflow が既存の `sync-projects.yml` と正常に共存する
- `.sdlc-config` が存在しない場合、workflow はスキップされる
- workflow のログに十分な情報が出力され、デバッグ可能である

## References（参考資料）

- 既存 Workflow: `.github/workflows/sync-projects.yml`
- 参考コマンド: `.claude/commands/sdlc-init.md`
- GitHub Issue: https://github.com/lleizh/ai-driven-sdlc/issues/24
