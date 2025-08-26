#!/bin/bash
# A06_access_key_usage_report_markdown.sh

# ヘッダー（Markdown形式）
echo "| ユーザー名 | アクセスキーID | 作成日 | 最終使用日 | ステータス | 備考 |"
echo "|------------|------------------|--------|--------------|------------|------|"

# IAMユーザー一覧取得
USERNAMES=$(aws iam list-users --query 'Users[*].UserName' --output text)

for USERNAME in $USERNAMES; do
  # アクセスキー取得
  ACCESS_KEYS=$(aws iam list-access-keys --user-name "$USERNAME" --query 'AccessKeyMetadata[*]' --output json)

  echo "$ACCESS_KEYS" | jq -c '.[]' | while read -r KEY; do
    ACCESS_KEY_ID=$(echo "$KEY" | jq -r '.AccessKeyId')
    CREATED=$(echo "$KEY" | jq -r '.CreateDate')
    STATUS=$(echo "$KEY" | jq -r '.Status')

    # 最終使用日の取得（なければ N/A）
    LAST_USED=$(aws iam get-access-key-last-used --access-key-id "$ACCESS_KEY_ID" \
      --query 'AccessKeyLastUsed.LastUsedDate' --output text 2>/dev/null)

    if [[ "$LAST_USED" == "None" || -z "$LAST_USED" ]]; then
      LAST_USED="N/A"
    fi

    echo "| $USERNAME | $ACCESS_KEY_ID | $CREATED | $LAST_USED | $STATUS | |"
  done
done

# 実行ログ追記
echo "$(date +%F) | A06 実行完了" >> evidence_execution_log.md
