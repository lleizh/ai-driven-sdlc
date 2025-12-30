# Release Plan（リリース計画）

**Feature ID**: {FEATURE_ID}  
**Release Version**（リリースバージョン）: {VERSION}  
**Target Release Date**（リリース予定日）: {DATE}  
**Release Manager**（リリースマネージャー）: {NAME}  
**Risk Level**（リスクレベル）: LOW | MEDIUM | HIGH

---

## Release Overview（リリース概要）

**Release Type**（リリース種別）: Major | Minor | Patch | Hotfix

**Summary**（概要）:
<!-- リリースの概要と主要な変更内容 -->


**Impact**（影響）:
- **Users**（ユーザー）: {ユーザーへの影響}
- **System**（システム）: {システムへの影響}
- **Downtime**（ダウンタイム）: Yes/No - {duration if applicable}

---

## Pre-Release Checklist（リリース前チェックリスト）

### Code Quality（コード品質）
- [ ] All tests passing（全テスト成功） (unit, integration, e2e)
- [ ] Code coverage ≥ {threshold}%
- [ ] Security scan completed（セキュリティスキャン完了）
- [ ] Performance benchmarks met（パフォーマンス基準達成）
- [ ] Code review approved（コードレビュー承認）

### Documentation（ドキュメント）
- [ ] User documentation updated（ユーザードキュメント更新）
- [ ] API documentation updated（APIドキュメント更新）
- [ ] CHANGELOG updated（CHANGELOG更新）
- [ ] Release notes prepared（リリースノート作成）

### Infrastructure（インフラ）
- [ ] Database migrations tested（データベースマイグレーションテスト済み）
- [ ] Configuration updated（設定更新済み）
- [ ] Monitoring/alerting configured（監視・アラート設定済み）

---

## Release Components（リリースコンポーネント）

### Services（サービス）
| サービス | バージョン | 変更内容 | デプロイ順序 |
|---------|-----------|---------|-------------|
| | | | 1 |
| | | | 2 |

### Database Changes（データベース変更）
| マイグレーション | 種別 | リスク | ロールバック可能 |
|----------------|------|--------|----------------|
| {migration-name} | Schema/Data | High/Medium/Low | Yes/No |

**Notes**（注意事項）:
<!-- データベース変更に関する特記事項 -->
- 
- 

---

## Deployment Plan（デプロイ計画）

### Deployment Strategy（デプロイ戦略）
**Selected**（選択）: Blue-Green | Rolling Update | Canary | Feature Flag

**Rationale**（理由）:
<!-- なぜこの戦略を選択したか -->


### Deployment Steps（デプロイ手順）

#### 1. Pre-Deployment（デプロイ前）
<!-- デプロイ前の準備作業 -->
```bash
# Step 1: {説明}
{command}

# Step 2: {説明}
{command}
```

**Validation**（検証）:
- [ ] {検証項目1}
- [ ] {検証項目2}

---

#### 2. Deployment（デプロイ）
<!-- 実際のデプロイ作業 -->
```bash
# Step 1: {説明}
{command}

# Step 2: {説明}
{command}
```

**Expected Duration**（予想時間）: {time}

**Validation**（検証）:
- [ ] Service health check passed（サービスヘルスチェック成功）
- [ ] Database migration completed（データベースマイグレーション完了）
- [ ] {その他の検証項目}

---

#### 3. Post-Deployment（デプロイ後）
<!-- デプロイ後の確認作業 -->
```bash
# Step 1: {説明}
{command}

# Step 2: {説明}
{command}
```

**Validation**（検証）:
- [ ] Smoke tests passed（スモークテスト成功）
- [ ] Metrics within normal range（メトリクスが正常範囲内）
- [ ] {その他の検証項目}

---

### Deployment Window（デプロイ時間枠）
- **Scheduled Time**（予定時刻）: {YYYY-MM-DD HH:MM timezone}
- **Duration**（所要時間）: {estimated time}
- **Maintenance Window**（メンテナンス時間）: Yes/No
- **User Impact**（ユーザー影響）: {description}

---

## Feature Flags（フィーチャーフラグ）
<!-- Feature Flag を使用する場合のみ記入 -->

### Flags（フラグ）
| フラグ名 | 初期状態 | ロールアウト戦略 |
|---------|---------|----------------|
| {flag-name} | OFF | Gradual (0% → 10% → 50% → 100%) |

### Rollout Timeline（ロールアウトスケジュール）
1. **Deploy with flag OFF**（フラグOFFでデプロイ） - {date/time}
2. **Enable for internal (10%)**（内部ユーザーに有効化 10%） - {date/time}
3. **Enable for beta (50%)**（ベータユーザーに有効化 50%） - {date/time}
4. **Enable for all (100%)**（全ユーザーに有効化 100%） - {date/time}
5. **Remove flag**（フラグ削除） - {date} (after {period})

---

## Monitoring & Validation（監視と検証）

### Key Metrics（主要メトリクス）
<!-- リリース後に監視すべき重要なメトリクス -->
| メトリクス | ベースライン | 閾値 | アラート |
|-----------|------------|------|---------|
| Error rate（エラー率） | {value} | < {threshold}% | Yes |
| Response time（応答時間） | {value}ms | < {threshold}ms | Yes |
| Throughput（スループット） | {value} req/s | > {threshold} | Yes |
| CPU usage（CPU使用率） | {value}% | < {threshold}% | No |
| Memory usage（メモリ使用率） | {value}GB | < {threshold}GB | No |

### Smoke Tests（スモークテスト）
<!-- デプロイ直後に実行する基本動作確認 -->
- [ ] {Critical path 1}
- [ ] {Critical path 2}
- [ ] {Critical path 3}

### Validation Period（検証期間）
- **Duration**（期間）: {time period, e.g., 24 hours}
- **Success Criteria**（成功基準）:
  - Error rate < {threshold}%
  - No critical bugs（クリティカルバグなし）
  - Performance within target（パフォーマンスが目標内）

---

## Rollback Plan（ロールバック計画）

### Rollback Triggers（ロールバックトリガー）
<!-- 以下の条件でロールバックを実行 -->
- ❌ Error rate > {threshold}%（エラー率が閾値超過）
- ❌ Response time > {threshold}ms（応答時間が閾値超過）
- ❌ Critical bug discovered（重大なバグ発見）
- ❌ Data integrity issue（データ整合性問題）

### Rollback Steps（ロールバック手順）
<!-- 問題発生時のロールバック手順 -->
```bash
# Step 1: {説明}
{command}

# Step 2: {説明}
{command}

# Step 3: {説明}
{command}
```

**Rollback Duration**（ロールバック所要時間）: {time}

**Data Rollback**（データロールバック）:
<!-- データベース変更がある場合のロールバック方法 -->
- **Strategy**（戦略）: {manual/automated}
- **Steps**（手順）:
  1. 
  2. 

---

## Risk Management（リスク管理）

### High Risk Items（高リスク項目）
<!-- risks.md から High Risk を抽出 -->

#### Risk R001: {リスクタイトル}
**Mitigation**（軽減策）:
<!-- このリスクに対するリリース時の軽減策 -->
- 
- 

**Contingency**（緊急対応）:
<!-- リスクが現実化した場合の対応 -->
- 
- 

---

### Medium Risk Items（中リスク項目）
| リスク | 軽減策 | 緊急対応 |
|--------|--------|---------|
| | | |

---

## Communication Plan（コミュニケーション計画）

### Pre-Release Notifications（リリース前通知）
<!-- 関係者への事前通知 -->
- [ ] Internal team（内部チーム） - {date}
- [ ] Stakeholders（ステークホルダー） - {date}
- [ ] Customer support（カスタマーサポート） - {date}
- [ ] Users (if applicable)（ユーザー（該当する場合）） - {date}

### During Release（リリース中）
<!-- リリース中のコミュニケーション方法 -->
- **Status Channel**（ステータスチャネル）: {Slack/Email/etc.}
- **Update Frequency**（更新頻度）: {interval}
- **Escalation Contact**（エスカレーション連絡先）: {name/channel}

### Post-Release Announcement（リリース後アナウンス）
<!-- リリース完了後のアナウンス -->
- **Timing**（タイミング）: {when}
- **Channels**（チャネル）: {blog/email/status page}
- **Message**（メッセージ）: {brief description}

---

## Post-Release Activities（リリース後の活動）

### Day 1（1日目）
<!-- リリース直後の即時対応 -->
- [ ] Monitor key metrics（主要メトリクスを監視）
- [ ] Review error logs（エラーログをレビュー）
- [ ] Validate critical paths（クリティカルパスを検証）
- [ ] Collect initial feedback（初期フィードバックを収集）

### Week 1（1週目）
<!-- 1週間以内の短期対応 -->
- [ ] Analyze performance data（パフォーマンスデータを分析）
- [ ] Review support tickets（サポートチケットをレビュー）
- [ ] Address quick fixes（クイックフィックスに対応）
- [ ] Update documentation (if needed)（ドキュメントを更新（必要な場合））

### Month 1（1か月目）
<!-- 1か月以内の長期対応 -->
- [ ] Conduct retrospective（振り返りを実施）
- [ ] Measure success metrics（成功指標を測定）
- [ ] Plan improvements（改善を計画）
- [ ] Archive release artifacts（リリース成果物をアーカイブ）

---

## Success Criteria（成功基準）

### Mandatory（必須）
<!-- 全リスクレベル共通の成功基準 -->
- [ ] Zero critical bugs in first 24 hours（最初の24時間でクリティカルバグゼロ）
- [ ] Error rate within baseline ± {threshold}%（エラー率がベースライン ± 閾値内）
- [ ] Performance metrics meet targets（パフォーマンスメトリクスが目標達成）
- [ ] No emergency rollbacks required（緊急ロールバック不要）

### Risk-Level Specific（リスクレベル別）

**High Risk**（高リスクの場合はさらに以下も必須）:
- [ ] Security validation passed（セキュリティ検証成功）
- [ ] Performance under load verified（負荷時のパフォーマンス検証済み）
- [ ] Data integrity confirmed（データ整合性確認済み）

---

## Release Notes（リリースノート）

### New Features（新機能）
- 
- 

### Improvements（改善）
- 
- 

### Bug Fixes（バグ修正）
- 
- 

### Breaking Changes（破壊的変更）
<!-- 該当する場合のみ記入 -->
- 
- 

**Migration Guide**（マイグレーションガイド）:
<!-- Breaking Changes がある場合のマイグレーション手順 -->
```
Step 1: 
Step 2: 
```

---

## Approval（承認）

<!-- リリース実行前に必要な承認 -->
- [ ] Tech Lead（テックリード）: {Name} - {Date}
- [ ] Product Owner（プロダクトオーナー）: {Name} - {Date}
- [ ] Release Manager（リリースマネージャー）: {Name} - {Date}
- [ ] Security Review (High Risk only)（セキュリティレビュー（高リスクのみ））: {Name} - {Date}

---

## Retrospective（振り返り）
<!-- リリース後に記入 -->

**Release Date**（実際のリリース日）: {DATE}  
**Status**（ステータス）: Success | Partial Success | Failed

### What Went Well（うまくいったこと）
- 
- 

### What Could Be Improved（改善できること）
- 
- 

### Action Items（アクション項目）
- [ ] {Item 1}
- [ ] {Item 2}

---

## Notes（備考）
<!-- その他のメモや特記事項 -->
- 
- 
