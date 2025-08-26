#!/bin/bash
# B03_cloudwatch_alarm_report_markdown.sh

REGION="ap-northeast-1"

# マークダウンヘッダー
echo "| アラーム名 | メトリクス名 | 名前空間 | 閾値 | 比較演算子 | 状態 | 対象リソース | アクション先 | 備考 |"
echo "|-------------|--------------|-----------|-------|---------------|--------|----------------|---------------|------|"

# アラーム一覧取得
ALARMS=$(aws cloudwatch describe-alarms --region "$REGION" --query 'MetricAlarms' --output json)

echo "$ALARMS" | jq -c '.[]' | while read -r alarm; do
  NAME=$(echo "$alarm" | jq -r '.AlarmName')
  METRIC=$(echo "$alarm" | jq -r '.MetricName')
  NAMESPACE=$(echo "$alarm" | jq -r '.Namespace')
  THRESHOLD=$(echo "$alarm" | jq -r '.Threshold')
  OPERATOR=$(echo "$alarm" | jq -r '.ComparisonOperator')
  STATE=$(echo "$alarm" | jq -r '.StateValue')
  
  DIMENSIONS=$(echo "$alarm" | jq -r '.Dimensions[]? | "\(.Name)=\(.Value)"' | paste -sd "," -)
  DIMENSIONS=${DIMENSIONS:-"-"}

  ACTIONS=$(echo "$alarm" | jq -r '.AlarmActions[]?' | paste -sd "," -)
  ACTIONS=${ACTIONS:-"-"}

  echo "| $NAME | $METRIC | $NAMESPACE | $THRESHOLD | $OPERATOR | $STATE | $DIMENSIONS | $ACTIONS | |"
done

# 実行ログ記録
echo "$(date +%F) | B03 実行完了" >> evidence_execution_log.md
