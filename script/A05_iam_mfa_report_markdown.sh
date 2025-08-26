#!/bin/bash
# A05_iam_mfa_report_markdown.sh

# ヘッダー（Markdown形式）
echo "| ユーザー名 | MFAデバイス登録数 | MFA有効？ | デバイスARN | 備考 |"
echo "|------------|--------------------|------------|--------------|------|"

# IAMユーザー一覧取得
USERNAMES=$(aws iam list-users --query 'Users[*].UserName' --output text)

for USERNAME in $USERNAMES; do
  # MFAデバイス情報取得
  MFA_DEVICES_JSON=$(aws iam list-mfa-devices --user-name "$USERNAME" --output json)
  MFA_COUNT=$(echo "$MFA_DEVICES_JSON" | jq '.MFADevices | length')

  if [[ "$MFA_COUNT" -gt 0 ]]; then
    # 複数デバイスがあっても1つ目だけ表示（通常1つ）
    DEVICE_ARN=$(echo "$MFA_DEVICES_JSON" | jq -r '.MFADevices[0].SerialNumber')
    MFA_ENABLED="✅"
  else
    DEVICE_ARN="-"
    MFA_ENABLED="❌"
  fi

  echo "| $USERNAME | $MFA_COUNT | $MFA_ENABLED | $DEVICE_ARN | |"
done

# 実行ログ追記
echo "$(date +%F) | A05 実行完了" >> evidence_execution_log.md
