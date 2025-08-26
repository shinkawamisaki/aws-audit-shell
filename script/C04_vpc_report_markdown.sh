#!/bin/bash
# C04_vpc_report_markdown.sh

REGION="ap-northeast-1"

# ヘッダー（Markdown形式）
echo "| VPC ID | CIDR | サブネットID | AZ | サブネットCIDR | パブリック | IGW | NATGW | 備考 |"
echo "|--------|------|--------------|----|----------------|------------|-----|-------|------|"

# VPC一覧取得
VPCS=$(aws ec2 describe-vpcs --region "$REGION" --query 'Vpcs[*].VpcId' --output text)

for VPC in $VPCS; do
  VPC_CIDR=$(aws ec2 describe-vpcs --vpc-ids "$VPC" --region "$REGION" --query 'Vpcs[0].CidrBlock' --output text)

  # サブネット取得
  SUBNETS=$(aws ec2 describe-subnets --filters Name=vpc-id,Values="$VPC" --region "$REGION" --query 'Subnets[*]' --output json)

  echo "$SUBNETS" | jq -c '.[]' | while read -r subnet; do
    SUBNET_ID=$(echo "$subnet" | jq -r '.SubnetId')
    AZ=$(echo "$subnet" | jq -r '.AvailabilityZone')
    CIDR=$(echo "$subnet" | jq -r '.CidrBlock')
    MAP_PUBLIC=$(echo "$subnet" | jq -r '.MapPublicIpOnLaunch')
    PUBLIC="❌"
    [[ "$MAP_PUBLIC" == "true" ]] && PUBLIC="✅"

    # IGW 判定
    IGW_ATTACHED="❌"
    IGWS=$(aws ec2 describe-internet-gateways \
      --filters Name=attachment.vpc-id,Values="$VPC" \
      --region "$REGION" \
      --query 'InternetGateways[*].InternetGatewayId' --output text)
    [[ -n "$IGWS" ]] && IGW_ATTACHED="✅"

    # NATGW 判定（該当サブネットに存在するか）
    NATGWS=$(aws ec2 describe-nat-gateways \
      --filter Name=subnet-id,Values="$SUBNET_ID" \
      --region "$REGION" \
      --query 'NatGateways[*].NatGatewayId' --output text)
    NATGW="❌"
    [[ -n "$NATGWS" ]] && NATGW="✅"

    echo "| $VPC | $VPC_CIDR | $SUBNET_ID | $AZ | $CIDR | $PUBLIC | $IGW_ATTACHED | $NATGW | |"
  done
done

# 実行ログ
echo "$(date +%F) | C04 実行完了" >> evidence_execution_log.md
