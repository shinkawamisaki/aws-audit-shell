#!/bin/bash
# E01_ses_report_markdown.sh

REGION="ap-northeast-1"

# ヘッダー
echo "| Identity名 | 種別 | 検証状態 | DKIM有効 | 備考 |"
echo "|-------------|--------|------------|------------|------|"

# Identity一覧取得
IDENTITIES=$(aws ses list-identities --region "$REGION" --query 'Identities[*]' --output text)

for IDENTITY in $IDENTITIES; do
  TYPE="その他"
  [[ "$IDENTITY" == *@* ]] && TYPE="EmailAddress" || TYPE="Domain"

  VERIFY_STATUS=$(aws ses get-identity-verification-attributes \
    --identities "$IDENTITY" \
    --region "$REGION" \
    --query "VerificationAttributes.\"$IDENTITY\".VerificationStatus" \
    --output text)

  [[ "$VERIFY_STATUS" == "Success" ]] && VERIFIED="✅" || VERIFIED="❌"

  DKIM_ENABLED=$(aws ses get-identity-dkim-attributes \
    --identities "$IDENTITY" \
    --region "$REGION" \
    --query "DkimAttributes.\"$IDENTITY\".DkimEnabled" \
    --output text)

  [[ "$DKIM_ENABLED" == "True" ]] && DKIM="✅" || DKIM="❌"

  echo "| $IDENTITY | $TYPE | $VERIFIED | $DKIM | |"
      # 実行ログに追記（進捗表更新用）
  echo "$(date +%F) | E01 実行完了" >> evidence_execution_log.md

done