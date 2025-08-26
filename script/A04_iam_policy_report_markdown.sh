#!/bin/bash
# A04_iam_policy_report_markdown.sh

REGION="ap-northeast-1"

# マークダウンヘッダー
echo "| ポリシー名 | ポリシーID | 作成日 | 最終更新日 | アタッチ先タイプ | アタッチ先数 | 備考 |"
echo "|------------|-------------|----------|----------------|-------------------|---------------|------|"

# カスタムポリシーのみ取得（AWS管理ポリシーは除外）
POLICIES=$(aws iam list-policies --scope Local --query 'Policies[*].Arn' --output text)

for POLICY_ARN in $POLICIES; do
  POLICY_DETAIL=$(aws iam get-policy --policy-arn "$POLICY_ARN")
  
  NAME=$(echo "$POLICY_DETAIL" | jq -r '.Policy.PolicyName')
  ID=$(echo "$POLICY_DETAIL" | jq -r '.Policy.PolicyId')
  CREATED=$(echo "$POLICY_DETAIL" | jq -r '.Policy.CreateDate')
  UPDATED=$(echo "$POLICY_DETAIL" | jq -r '.Policy.UpdateDate')

  ATTACHMENTS=$(echo "$POLICY_DETAIL" | jq -r '.Policy.AttachmentCount')
  ATTACHMENT_TYPE="-"

  # アタッチされてる場合、アタッチ先を確認
  if [ "$ATTACHMENTS" -gt 0 ]; then
    ENTITIES=$(aws iam list-entities-for-policy --policy-arn "$POLICY_ARN" --query '{Users:PolicyUsers[*].UserName, Roles:PolicyRoles[*].RoleName, Groups:PolicyGroups[*].GroupName}' --output json)
    USER_COUNT=$(echo "$ENTITIES" | jq '.Users | length')
    ROLE_COUNT=$(echo "$ENTITIES" | jq '.Roles | length')
    GROUP_COUNT=$(echo "$ENTITIES" | jq '.Groups | length')

    ATTACHMENT_TYPE=""
    [[ $USER_COUNT -gt 0 ]] && ATTACHMENT_TYPE+="ユーザー "
    [[ $ROLE_COUNT -gt 0 ]] && ATTACHMENT_TYPE+="ロール "
    [[ $GROUP_COUNT -gt 0 ]] && ATTACHMENT_TYPE+="グループ "
  fi

  echo "| $NAME | $ID | $CREATED | $UPDATED | ${ATTACHMENT_TYPE:-なし} | $ATTACHMENTS | |"
done

# 実行ログ
echo "$(date +%F) | A04 実行完了" >> evidence_execution_log.md
