#!/bin/bash
# C01_ec2_instance_report_markdown.sh

REGION="ap-northeast-1"

# ヘッダー（Markdown形式）
echo "| インスタンスID | 名前タグ | 稼働状態 | インスタンスタイプ | AZ | パブリックIP | IAMロール | セキュリティグループ | キーペア名 | 起動時刻 | 停止保護 | 備考 |"
echo "|----------------|----------|----------|------------------|----|--------------|------------|---------------------|------------|----------|----------|------|"

# EC2インスタンス一覧取得
INSTANCES=$(aws ec2 describe-instances --region $REGION \
  --query 'Reservations[*].Instances[*]' --output json)

echo "$INSTANCES" | jq -c '.[][]' | while read -r instance; do
  ID=$(echo "$instance" | jq -r '.InstanceId')
  NAME=$(echo "$instance" | jq -r '.Tags[]? | select(.Key=="Name") | .Value' | head -n1)
  NAME=${NAME:-"-"}

  STATE=$(echo "$instance" | jq -r '.State.Name')
  TYPE=$(echo "$instance" | jq -r '.InstanceType')
  AZ=$(echo "$instance" | jq -r '.Placement.AvailabilityZone')
  PUBIP=$(echo "$instance" | jq -r '.PublicIpAddress // "なし"')
  IAM_ROLE=$(echo "$instance" | jq -r '.IamInstanceProfile.Arn // "-"')
  SG=$(echo "$instance" | jq -r '.SecurityGroups[].GroupName' | paste -sd "," -)
  KEYNAME=$(echo "$instance" | jq -r '.KeyName // "-"')
  LAUNCH_TIME=$(echo "$instance" | jq -r '.LaunchTime')

  INSTANCE_DETAIL=$(aws ec2 describe-instance-attribute --instance-id "$ID" \
    --attribute disableApiTermination --region $REGION)
  DISABLE_API_TERMINATION=$(echo "$INSTANCE_DETAIL" | jq -r '.DisableApiTermination.Value')
  if [[ "$DISABLE_API_TERMINATION" == "true" ]]; then
    TERMINATION_PROTECTION="✅"
  else
    TERMINATION_PROTECTION="❌"
  fi

  echo "| $ID | $NAME | $STATE | $TYPE | $AZ | $PUBIP | $IAM_ROLE | $SG | $KEYNAME | $LAUNCH_TIME | $TERMINATION_PROTECTION | |"
    # 実行ログに追記（進捗表更新用）
  echo "$(date +%F) | C01 実行完了" >> evidence_execution_log.md

done