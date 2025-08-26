#!/bin/bash
# D01_s3_bucket_report_markdown.sh

REGION="ap-northeast-1"

# ヘッダー（Markdown形式）
echo "| バケット名 | リージョン | 作成日 | パブリックアクセス | バージョニング | 暗号化 | 備考 |"
echo "|------------|------------|--------|---------------------|----------------|--------|------|"

# バケット一覧取得
BUCKETS_JSON=$(aws s3api list-buckets)
BUCKET_NAMES=$(echo "$BUCKETS_JSON" | jq -r '.Buckets[].Name')

for BUCKET in $BUCKET_NAMES; do
  CREATED=$(echo "$BUCKETS_JSON" | jq -r ".Buckets[] | select(.Name==\"$BUCKET\") | .CreationDate")

  # リージョン取得
  LOCATION=$(aws s3api get-bucket-location --bucket "$BUCKET" --output text 2>/dev/null)
  [ "$LOCATION" == "None" ] && LOCATION="us-east-1"
  [ -z "$LOCATION" ] && LOCATION="取得不可"

  # パブリックアクセス判定
  PUBLIC_STATUS=$(aws s3api get-bucket-policy-status --bucket "$BUCKET" 2>/dev/null \
    | jq -r '.PolicyStatus.IsPublic // "false"')
  PUBLIC="❌"
  [ "$PUBLIC_STATUS" == "true" ] && PUBLIC="⚠️"

  # バージョニング
  VERSIONING=$(aws s3api get-bucket-versioning --bucket "$BUCKET" 2>/dev/null \
    | jq -r '.Status // "無効"')
  [ -z "$VERSIONING" ] && VERSIONING="無効"

  # 暗号化
  ENCRYPTION=$(aws s3api get-bucket-encryption --bucket "$BUCKET" 2>/dev/null \
    | jq -r '.ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault.SSEAlgorithm' 2>/dev/null)
  [ -z "$ENCRYPTION" ] && ENCRYPTION="なし"

  # 備考（エラー等）
  NOTE=""
  if [[ "$LOCATION" == "取得不可" ]]; then NOTE="リージョン取得失敗"; fi

  echo "| $BUCKET | $LOCATION | $CREATED | $PUBLIC | $VERSIONING | $ENCRYPTION | $NOTE |"
      # 実行ログに追記（進捗表更新用）
  echo "$(date +%F) | D01 実行完了" >> evidence_execution_log.md

done