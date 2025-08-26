#!/bin/bash
# D04_secrets_ssm_report_markdown.sh

REGION="ap-northeast-1"

### Secrets Manager Report
echo ""
echo "| 名前 | 作成日 | KMS暗号化 | 自動ローテーション | ローテーション有効日 | 最終アクセス日 | タグ | 備考 |"
echo "|------|--------|-----------|------------------|------------------|----------------|------|------|"

SECRETS=$(aws secretsmanager list-secrets --region $REGION \
  --query 'SecretList[*].Name' --output text)

for NAME in $SECRETS; do
  SECRET=$(aws secretsmanager describe-secret --secret-id "$NAME" --region $REGION)
  CREATED=$(echo "$SECRET" | jq -r '.CreatedDate')
  KMS=$(echo "$SECRET" | jq -r '.KmsKeyId // "default (aws/secretsmanager)"')
  ROTATION=$(echo "$SECRET" | jq -r '.RotationEnabled')
  ROTATEDATE=$(echo "$SECRET" | jq -r '.LastRotatedDate // "-"')
  LASTUSED=$(echo "$SECRET" | jq -r '.LastAccessedDate // "-"')
  TAGS=$(echo "$SECRET" | jq -r '[.Tags[]? | "\(.Key)=\(.Value)"] | join(", ")')

  ROTATION_ICON="❌"
  [[ "$ROTATION" == "true" ]] && ROTATION_ICON="✅"

  echo "| $NAME | $CREATED | $KMS | $ROTATION_ICON | $ROTATEDATE | $LASTUSED | $TAGS | |"
done

### SSM SecureString Report
echo ""
echo "| 名前 | タイプ | 作成日 | KMS暗号化 | 最終変更日 | タグ | 備考 |"
echo "|------|--------|--------|-----------|------------|------|------|"

PARAMS=$(aws ssm describe-parameters --region $REGION \
  --query 'Parameters[*].Name' --output text)

for NAME in $PARAMS; do
  PARAM_DETAIL=$(aws ssm get-parameter --name "$NAME" --with-decryption --region $REGION 2>/dev/null)
  if [[ $? -ne 0 ]]; then
    continue  # 読み取れない（SecureStringじゃない or アクセス権なし）
  fi

  META=$(aws ssm describe-parameters --parameter-filters "Key=Name,Values=$NAME" \
    --region $REGION --query 'Parameters[0]' --output json)

  TYPE=$(echo "$META" | jq -r '.Type')
  if [[ "$TYPE" != "SecureString" ]]; then
    continue
  fi

  CREATED=$(aws ssm list-tags-for-resource --resource-type "Parameter" --resource-id "$NAME" --region $REGION \
    | jq -r '.Tags[]? | select(.Key=="CreatedDate") | .Value // "-"')

  MODIFIED=$(echo "$META" | jq -r '.LastModifiedDate')
  KMS=$(echo "$META" | jq -r '.KeyId // "default (aws/ssm)"')
  TAGS=$(aws ssm list-tags-for-resource --resource-type "Parameter" --resource-id "$NAME" --region $REGION \
    | jq -r '[.Tags[]? | "\(.Key)=\(.Value)"] | join(", ")')

  echo "| $NAME | $TYPE | $CREATED | $KMS | $MODIFIED | $TAGS | |"
      # 実行ログに追記（進捗表更新用）
  echo "$(date +%F) | D04 実行完了" >> evidence_execution_log.md

done