#!/bin/bash
# D02_s3_encryption_blockpublic_report.sh

REGION="ap-northeast-1"

# ヘッダー（Markdown形式）
echo "| バケット名 | リージョン | サーバーサイド暗号化 | 公開ブロック（全設定） | 備考 |"
echo "|------------|------------|----------------------|-------------------------|------|"

# バケット一覧取得
BUCKETS_JSON=$(aws s3api list-buckets --output json)
BUCKET_NAMES=$(echo "$BUCKETS_JSON" | jq -r '.Buckets[].Name')

for BUCKET in $BUCKET_NAMES; do
  # 作成時リージョン
  LOCATION=$(aws s3api get-bucket-location --bucket "$BUCKET" --output text)
  [[ "$LOCATION" == "None" ]] && LOCATION="us-east-1"

  # 暗号化状態取得
  ENCRYPTION=$(aws s3api get-bucket-encryption --bucket "$BUCKET" --region "$REGION" 2>/dev/null \
    | jq -r '.ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault.SSEAlgorithm' 2>/dev/null)
  [[ -z "$ENCRYPTION" ]] && ENCRYPTION="❌ 無効"

  # ブロックパブリックアクセス設定
  BLOCK_PUBLIC=$(aws s3api get-bucket-policy-status --bucket "$BUCKET" --region "$REGION" 2>/dev/null \
    | jq -r '.PolicyStatus.IsPublic')
  [[ "$BLOCK_PUBLIC" == "true" ]] && BLOCK_STATUS="❌ 公開" || BLOCK_STATUS="✅ 非公開"

  echo "| $BUCKET | $LOCATION | $ENCRYPTION | $BLOCK_STATUS | |"
done

echo "$(date +%F) | D02 実行完了" >> evidence_execution_log.md
