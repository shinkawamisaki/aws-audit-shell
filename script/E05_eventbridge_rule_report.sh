#!/bin/bash
# E05_eventbridge_rule_report.sh

REGION="ap-northeast-1"

# Markdownヘッダー
echo "| ルール名 | イベントバス | 状態 | スケジュール式 | ターゲット数 | 備考 |"
echo "|----------|--------------|------|----------------|---------------|------|"

# 全ルール取得（デフォルトイベントバス）
RULES=$(aws events list-rules --region "$REGION" --output json)

echo "$RULES" | jq -c '.Rules[]' | while read -r rule; do
  NAME=$(echo "$rule" | jq -r '.Name')
  BUS=$(echo "$rule" | jq -r '.EventBusName')
  STATE=$(echo "$rule" | jq -r '.State')
  SCHEDULE=$(echo "$rule" | jq -r '.ScheduleExpression // "-"')

  TARGETS=$(aws events list-targets-by-rule --region "$REGION" --rule "$NAME" --event-bus-name "$BUS" --output json)
  TARGET_COUNT=$(echo "$TARGETS" | jq '.Targets | length')

  echo "| $NAME | $BUS | $STATE | $SCHEDULE | $TARGET_COUNT | |"
done

echo "$(date +%F) | E05 実行完了" >> evidence_execution_log.md
