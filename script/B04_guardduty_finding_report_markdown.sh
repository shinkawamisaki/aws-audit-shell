#!/bin/bash
# B04_guardduty_finding_report_markdown.sh

REGION="ap-northeast-1"

# ガードデューティーのDetector ID取得
DETECTOR_ID=$(aws guardduty list-detectors --region "$REGION" --query 'DetectorIds[0]' --output text)

if [[ "$DETECTOR_ID" == "None" || -z "$DETECTOR_ID" ]]; then
  echo "GuardDuty が有効化されていません。"
  exit 1
fi

# マークダウンヘッダー
echo "| 検出ID | タイトル | 種別 | 検出日 | 深刻度 | リソースタイプ | 状態 | 備考 |"
echo "|--------|----------|------|--------|--------|----------------|------|------|"

# 検出結果一覧取得（最大50件）
FINDINGS=$(aws guardduty list-findings \
  --region "$REGION" \
  --detector-id "$DETECTOR_ID" \
  --max-results 50 \
  --query 'FindingIds' \
  --output json)

# 各検出の詳細取得
DETAILS=$(aws guardduty get-findings \
  --region "$REGION" \
  --detector-id "$DETECTOR_ID" \
  --finding-ids "$FINDINGS" \
  --output json)

# ここを修正 → .Findings[] に変更
echo "$DETAILS" | jq -c '.Findings[]' | while read -r finding; do
  ID=$(echo "$finding" | jq -r '.Id')
  TITLE=$(echo "$finding" | jq -r '.Title')
  TYPE=$(echo "$finding" | jq -r '.Type')
  TIME=$(echo "$finding" | jq -r '.UpdatedAt')
  SEVERITY=$(echo "$finding" | jq -r '.Severity')
  RESOURCE_TYPE=$(echo "$finding" | jq -r '.Resource.ResourceType')
  STATUS=$(echo "$finding" | jq -r '.Service.Status')

  echo "| $ID | $TITLE | $TYPE | $TIME | $SEVERITY | $RESOURCE_TYPE | $STATUS | |"
done

# 実行ログ記録
echo "$(date +%F) | B04 実行完了" >> evidence_execution_log.md