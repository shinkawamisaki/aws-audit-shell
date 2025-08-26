#!/bin/bash
# C06_rds_report_markdown.sh

REGION="ap-northeast-1"

# ヘッダー（Markdown形式）
echo "| DB識別子 | エンジン | エンジンバージョン | ステータス | マルチAZ | ストレージタイプ | 暗号化 | VPC | パブリックアクセス | 備考 |"
echo "|-----------|---------|-------------------|-----------|----------|----------------|--------|-----|------------------|------|"

# RDSインスタンス一覧取得
aws rds describe-db-instances --region "$REGION" --query 'DBInstances[*]' --output json | jq -c '.[]' | while read -r db; do
  IDENTIFIER=$(echo "$db" | jq -r '.DBInstanceIdentifier')
  ENGINE=$(echo "$db" | jq -r '.Engine')
  VERSION=$(echo "$db" | jq -r '.EngineVersion')
  STATUS=$(echo "$db" | jq -r '.DBInstanceStatus')
  MULTI_AZ=$(echo "$db" | jq -r '.MultiAZ')
  STORAGE_TYPE=$(echo "$db" | jq -r '.StorageType')
  ENCRYPTED=$(echo "$db" | jq -r '.StorageEncrypted')
  VPC=$(echo "$db" | jq -r '.DBSubnetGroup.VpcId')
  PUBLIC_ACCESS=$(echo "$db" | jq -r '.PubliclyAccessible')

  # 絵文字変換
  MULTI_AZ_ICON="❌"
  [[ "$MULTI_AZ" == "true" ]] && MULTI_AZ_ICON="✅"

  ENC_ICON="❌"
  [[ "$ENCRYPTED" == "true" ]] && ENC_ICON="✅"

  PUB_ICON="❌"
  [[ "$PUBLIC_ACCESS" == "true" ]] && PUB_ICON="✅"

  echo "| $IDENTIFIER | $ENGINE | $VERSION | $STATUS | $MULTI_AZ_ICON | $STORAGE_TYPE | $ENC_ICON | $VPC | $PUB_ICON | |"
done

echo "$(date +%F) | C06 実行完了" >> evidence_execution_log.md
