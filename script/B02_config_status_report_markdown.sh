#!/bin/bash
# B02_config_status_report_markdown.sh

REGION="ap-northeast-1"

# ヘッダー（Markdown形式）
echo "| リージョン | Config有効 | 配信先S3バケット | 配信先SNSトピック | 備考 |"
echo "|------------|-------------|-------------------|--------------------|------|"

# 各リージョンでConfig有効状況確認（デフォルトは指定リージョンのみ）
REGIONS=$(aws ec2 describe-regions --query 'Regions[*].RegionName' --output text)

for REGION in $REGIONS; do
  DELIVERY_CFG=$(aws configservice describe-delivery-channels --region "$REGION" 2>/dev/null)
  RECORDERS=$(aws configservice describe-configuration-recorders --region "$REGION" 2>/dev/null)
  STATUS=$(aws configservice describe-configuration-recorder-status --region "$REGION" 2>/dev/null)

  CHANNEL_NAME=$(echo "$DELIVERY_CFG" | jq -r '.DeliveryChannels[0].name // empty')
  S3_BUCKET=$(echo "$DELIVERY_CFG" | jq -r '.DeliveryChannels[0].s3BucketName // "-"')
  SNS_TOPIC=$(echo "$DELIVERY_CFG" | jq -r '.DeliveryChannels[0].snsTopicARN // "-"')
  IS_ENABLED=$(echo "$STATUS" | jq -r '.ConfigurationRecordersStatus[0].recording // "false"')

  if [[ "$IS_ENABLED" == "true" ]]; then
    CONFIG_STATUS="✅"
  else
    CONFIG_STATUS="❌"
  fi

  echo "| $REGION | $CONFIG_STATUS | $S3_BUCKET | $SNS_TOPIC | |"
done

# 実行ログ追記
echo "$(date +%F) | B02 実行完了" >> evidence_execution_log.md
