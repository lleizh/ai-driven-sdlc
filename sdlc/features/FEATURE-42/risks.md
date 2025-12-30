# Risks（リスク）

**Feature ID**: FEATURE-42  
**Last Updated**: 2025-12-30  
**Overall Risk Level**（総合リスクレベル）: MEDIUM

---

## Risk Assessment Summary（リスク評価サマリー）

| Risk ID | リスク | レベル | ステータス |
|---------|--------|--------|-----------|
| R001 | GitHub API Rate Limit | Medium | Open |
| R002 | 分類ロジックの精度 | Medium | Open |
| R003 | PR 検出の誤判定 | Low | Open |
| R004 | AI Bot 識別の網羅性 | Low | Open |

---

## Risk Level Criteria（リスクレベル基準）

### High Risk（高リスク）
**Definition**（定義）: 
- システム安定性、セキュリティ、データ整合性への重大な影響
- 複数システムまたは大規模ユーザーに影響
- ロールバックが困難または不可能

**Review Requirements**（レビュー要件）:
- Design Review 必須
- Security Review 必須
- 詳細な実装計画とテスト計画
- ロールバック戦略を含むリリース計画

### Medium Risk（中リスク）
**Definition**（定義）:
- 重大だが限定的な影響
- 特定のサブシステムまたはユーザーセグメントに影響
- 合理的な労力でロールバック可能

**Review Requirements**（レビュー要件）:
- Design Review 推奨
- 標準テストカバレッジ
- デプロイ計画

### Low Risk（低リスク）
**Definition**（定義）:
- 最小限の影響、局所的な変更
- 簡単にロールバック可能

**Review Requirements**（レビュー要件）:
- Code Review のみ
- 基本的なテストカバレッジ

---

## Detailed Risk Analysis（詳細リスク分析）

### Risk R001: GitHub API Rate Limit

**Level**（レベル）: MEDIUM  
**Status**（ステータス）: OPEN  
**Owner**（担当者）: TBD  
**Identified Date**（特定日）: 2025-12-30

#### Description（説明）

GitHub API には Rate Limit があり、多数の PR や大量のコメントを処理する際に制限に達する可能性があります。特に：
- `/sdlc-review-summary` を短時間に複数回実行する場合
- PR に大量のコメント（100件以上）がある場合
- 組織全体で複数のユーザーが同時に実行する場合

#### Impact（影響）
**If this risk materializes**（このリスクが現実化した場合）:
- **Users**（ユーザー）: コマンド実行が失敗する、エラーメッセージが表示される
- **System**（システム）: 一時的にコマンドが使用不可になる
- **Business**（ビジネス）: レビュー記録のタイミングが遅れる
- **Data**（データ）: データ損失はないが、記録が遅延する

**Likelihood**（発生確率）: Medium (10-50%)（頻繁には起きないが、可能性はある）

#### Root Cause（根本原因）

GitHub API の Rate Limit:
- **Authenticated requests**: 5,000 requests/hour
- **Search API**: 30 requests/minute

PR 1件につき、最低でも以下の API 呼び出しが必要:
1. `gh pr list`: 1 call
2. `gh api reviews`: 1 call
3. `gh api comments`: 1 call

合計 3 calls/feature。大量の feature を処理すると制限に達する可能性があります。

#### Mitigation Strategy（軽減戦略）

**Approach**（アプローチ）: Reduce

**Actions**（アクション）:
- [ ] Rate Limit をチェックし、制限に近い場合は警告を表示
- [ ] API レスポンスをキャッシュして、同じ PR への複数回の呼び出しを避ける
- [ ] エラー時に Rate Limit の残量とリセット時刻を表示
- [ ] 必要最小限の API 呼び出しに最適化（不要なフィールドは取得しない）

**Residual Risk**（残存リスク）: Low（軽減策を実装すれば、通常の使用では問題なし）

#### Contingency Plan（緊急対応計画）

Rate Limit に達した場合:
1. エラーメッセージで Rate Limit リセット時刻を表示
2. ユーザーに待機を促す
3. 急ぎの場合は手動で `40_review_findings.md` を作成

#### Monitoring（監視）
- **Metrics**（メトリクス）: API 呼び出し回数、Rate Limit 残量
- **Review Frequency**（レビュー頻度）: コマンド実行時に毎回チェック

---

### Risk R002: 分類ロジックの精度

**Level**（レベル）: MEDIUM  
**Status**（ステータス）: OPEN  
**Owner**（担当者）: TBD  
**Identified Date**（特定日）: 2025-12-30

#### Description（説明）

規則ベースの分類ロジックは、キーワードと Emoji に依存するため、以下のケースで誤分類の可能性があります：
- キーワードリストにない表現（例：「これは致命的な問題です」→ "critical" がないため Important と判定される可能性）
- Emoji を使わないレビュー
- 文脈依存の重要度（例：「Maybe this is a blocker?」→ キーワード "blocker" があるが疑問形なので Critical ではない）

#### Impact（影響）
**If this risk materializes**（このリスクが現実化した場合）:
- **Users**（ユーザー）: 重要な問題が Suggestions に分類され、見落とされる可能性
- **System**（システム）: システムへの影響はなし
- **Business**（ビジネス）: レビュー品質の低下、重要な指摘の見落とし

**Likelihood**（発生確率）: Medium (10-50%)（キーワードベースの限界）

#### Root Cause（根本原因）

規則ベースの分類エンジンは自然言語の文脈を理解できません。キーワードマッチングのみに依存するため、表現のバリエーションに対応できません。

#### Mitigation Strategy（軽減戦略）

**Approach**（アプローチ）: Reduce

**Actions**（アクション）:
- [ ] 包括的なキーワードリストを作成（日本語と英語の両方）
- [ ] Reviewer の state を優先的に考慮（`CHANGES_REQUESTED` は必ず Critical）
- [ ] デフォルトで Important に分類（安全側に倒す）
- [ ] ユーザーフィードバックを基にキーワードリストを継続的に改善
- [ ] （将来）LLM ベースの分類に移行する（Phase 3）

**Residual Risk**（残存リスク）: Low-Medium（完全には解消できないが、実用上は許容範囲）

#### Contingency Plan（緊急対応計画）

誤分類が発生した場合:
1. ユーザーが手動で `40_review_findings.md` を修正
2. 誤分類のパターンを報告してもらい、キーワードリストを更新
3. 次回のコマンド実行時には改善される

#### Monitoring（監視）
- **Metrics**（メトリクス）: 分類精度のフィードバック
- **Review Frequency**（レビュー頻度）: 月次でキーワードリストをレビュー

---

### Risk R003: PR 検出の誤判定

**Level**（レベル）: LOW  
**Status**（ステータス）: OPEN  
**Owner**（担当者）: TBD  
**Identified Date**（特定日）: 2025-12-30

#### Description（説明）

以下のケースで、意図しない PR を選択してしまう可能性があります：
- 同じ feature ブランチで複数の PR が open されている
- ブランチ名が標準的な命名規則（`feature/{FEATURE_ID}`）に従っていない
- 古い PR が open のまま残っている

#### Impact（影響）
**If this risk materializes**（このリスクが現実化した場合）:
- **Users**（ユーザー）: 間違った PR の Review を記録してしまう
- **System**（システム）: システムへの影響はなし
- **Business**（ビジネス）: 記録の正確性が低下

**Likelihood**（発生確率）: Low (<10%)（標準的なワークフローでは発生しにくい）

#### Root Cause（根本原因）

PR 検出ロジックが「最新の open PR」を選択するため、複数 PR がある場合の挙動が不明確です。

#### Mitigation Strategy（軽減戦略）

**Approach**（アプローチ）: Reduce

**Actions**（アクション）:
- [ ] PR 検出時に、選択された PR 番号とタイトルを表示（ユーザーに確認を促す）
- [ ] 複数 PR がある場合は警告メッセージを表示
- [ ] エラーメッセージで「PR が意図したものでない場合は手動で修正してください」と案内
- [ ] （将来）`--pr <number>` オプションを追加して手動指定を可能にする

**Residual Risk**（残存リスク）: Low（警告メッセージで十分対応可能）

#### Contingency Plan（緊急対応計画）

誤った PR を選択した場合:
1. ユーザーが気付いたら、手動で `40_review_findings.md` を修正
2. 正しい PR 番号を指定して再実行（将来の `--pr` オプション）

---

### Risk R004: AI Bot 識別の網羅性

**Level**（レベル）: LOW  
**Status**（ステータス）: OPEN  
**Owner**（担当者）: TBD  
**Identified Date**（特定日）: 2025-12-30

#### Description（説明）

AI Bot の識別リストが不完全な場合、新しい AI Review Bot や未知の Bot を Human Reviewer として扱ってしまう可能性があります。

#### Impact（影響）
**If this risk materializes**（このリスクが現実化した場合）:
- **Users**（ユーザー）: AI のコメントが Human のコメントとして記録される
- **System**（システム）: システムへの影響はなし
- **Business**（ビジネス）: クロス分析の精度が低下

**Likelihood**（発生確率）: Low (<10%)（Phase 2 の機能、かつ主要な Bot はカバー予定）

#### Root Cause（根本原因）

AI Bot は継続的に新しいものが登場するため、静的なリストでは完全に網羅できません。

#### Mitigation Strategy（軽減戦略）

**Approach**（アプローチ）: Accept + Monitor

**Actions**（アクション）:
- [ ] 主要な AI Bot（CodeRabbit, Copilot, Sourcery 等）をカバーする
- [ ] Bot 識別パターンを柔軟に（`[bot]` サフィックス、`-ai` サフィックス等）
- [ ] ユーザーフィードバックで新しい Bot を追加
- [ ] ドキュメントに「未知の Bot は Human として扱われる」と明記

**Residual Risk**（残存リスク）: Low（実用上は許容範囲、Phase 2 の機能）

#### Contingency Plan（緊急対応計画）

未知の Bot が Human として扱われた場合:
1. ユーザーからのフィードバックを受け付ける
2. Bot リストに追加して次回リリースに含める
3. 急ぎの場合はユーザーが手動で修正

---

## Risk Categories（リスクカテゴリー）

### Technical Risks（技術的リスク）
- R001: GitHub API Rate Limit
- R002: 分類ロジックの精度

### Operational Risks（運用リスク）
- R003: PR 検出の誤判定

### Security Risks（セキュリティリスク）
（現時点では識別されたセキュリティリスクなし）

### Data Risks（データリスク）
（データ損失のリスクなし。既存データの読み取りと新規ファイル作成のみ）

### Dependency Risks（依存関係リスク）
- R001: GitHub API への依存
- R004: AI Bot 識別の網羅性

---

## Risk Matrix（リスクマトリックス）

|           | 低影響 | 中影響 | 高影響 |
|-----------|--------|--------|--------|
| **高確率** | Medium | High | Critical |
| **中確率** | Low | Medium | High |
| **低確率** | Low | Low | Medium |

### Current Risks Plotted（現在のリスクプロット）
- **Critical**（クリティカル）: 0
- **High**（高）: 0
- **Medium**（中）: 2 - R001, R002
- **Low**（低）: 2 - R003, R004

---

## Accepted Risks（受け入れたリスク）

### Risk: R004 - AI Bot 識別の網羅性

**Reason for Acceptance**（受け入れ理由）:
- Phase 2 のオプション機能であり、必須ではない
- 主要な AI Bot はカバー予定
- 未知の Bot は Human として扱われても大きな問題にはならない
- ユーザーフィードバックで継続的に改善可能

**Conditions**（条件）:
- 主要な AI Bot（CodeRabbit, Copilot, Sourcery, GitHub Actions Bot, Qodo）はカバーする
- ドキュメントに制限事項を明記する
- ユーザーフィードバックの仕組みを用意する

**Approver**（承認者）: TBD  
**Date**（日付）: TBD

---

## Risk Review History（リスクレビュー履歴）

| 日付 | レビュアー | 変更内容 | 備考 |
|------|-----------|---------|------|
| 2025-12-30 | - | 初回リスク評価 | 4つのリスクを識別 |

---

## Notes（備考）

- このプロジェクトは Medium Risk と評価されています
- 既存のワークフローを破壊しない（新規コマンド追加）
- オプション機能であり、使わなくても良い
- 失敗してもロールバックは容易（コマンドを使わなければ良い）
