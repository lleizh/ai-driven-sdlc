# Design（設計）

**Feature ID**: {FEATURE_ID}  
**Last Updated**: {DATE}  
**Status**: DRAFT | UNDER_REVIEW | APPROVED

## Overview（概要）
<!-- 設計の全体像を 2-3 段落で説明 -->

## Architecture（アーキテクチャ）

### System Architecture（システムアーキテクチャ）
<!-- システムアーキテクチャ図（必要に応じて） -->
```
[Component A] --> [Component B] --> [Database]
      |
      v
[External Service]
```

### Component Design（コンポーネント設計）
<!-- 各コンポーネントの責務と関係 -->

#### Component: {名前}
**Responsibility**（責務）: 
**Interfaces**（インターフェース）: 
**Dependencies**（依存関係）: 

#### Component: {名前}
**Responsibility**（責務）: 
**Interfaces**（インターフェース）: 
**Dependencies**（依存関係）: 

## Data Design（データ設計）

### Database Schema Changes（スキーマ変更）
<!-- スキーマ変更がある場合 -->
```sql
CREATE TABLE example (
    id BIGINT PRIMARY KEY,
    field VARCHAR(255),
    created_at TIMESTAMP
);
```

### Migration Strategy（マイグレーション戦略）
<!-- マイグレーション戦略 -->
1. 
2. 

### Data Flow（データフロー）
<!-- データの流れ -->
```
User Input --> Validation --> Business Logic --> Database --> Response
```

## API Design（API設計）

### Endpoint 1: {METHOD} {PATH}
**Purpose**（目的）: 

**Request**（リクエスト）:
```json
{
  "example": "request"
}
```

**Response**（レスポンス）:
```json
{
  "example": "response"
}
```

**Business Logic**（ビジネスロジック）:
1. 
2. 

## Security Considerations（セキュリティの考慮事項）
<!-- セキュリティ上の考慮事項 -->
- [ ] Input validation（入力検証）
- [ ] Authentication/Authorization（認証・認可）
- [ ] Data encryption（データ暗号化）
- [ ] Rate limiting（レート制限）
- [ ] Audit logging（監査ログ）

## Error Handling（エラー処理）
<!-- エラー処理の方針 -->
| エラー種別 | 処理方針 | ユーザーメッセージ |
|------------|----------|-------------------|
| Validation | | |
| Business Logic | | |
| System | | |

## Performance Considerations（パフォーマンスの考慮事項）
<!-- パフォーマンスの考慮事項 -->
- Caching strategy（キャッシュ戦略）: 
- Database indexes（データベースインデックス）: 
- Query optimization（クエリ最適化）: 
- Async processing（非同期処理）: 

## Scalability Considerations（スケーラビリティの考慮事項）
<!-- スケーラビリティの考慮事項 -->
- Horizontal scaling（水平スケーリング）: 
- Load balancing（負荷分散）: 
- Resource limits（リソース制限）: 

## Monitoring & Observability（監視と可観測性）
<!-- 監視・可観測性の設計 -->

### Metrics（メトリクス）
- 
- 

### Logs（ログ）
- 
- 

### Alerts（アラート）
- 
- 

## Alternative Designs Considered（検討した代替設計）
<!-- 検討した他の設計案とその理由 -->

### Alternative 1: {名前}
**Pros**（長所）: 
**Cons**（短所）: 
**Why Rejected**（却下理由）: 

### Alternative 2: {名前}
**Pros**（長所）: 
**Cons**（短所）: 
**Why Rejected**（却下理由）: 

## Open Questions（未解決の問題）
<!-- 未解決の問題や要確認事項 -->
- [ ] 
- [ ] 

## References（参考資料）
<!-- 参考資料 -->
- 
- 
