#!/bin/bash
# D04_secrets_ssm_report_markdown.sh（値は取得しない版：Secrets と SSM SecureString のメタのみ）
set -euo pipefail
export AWS_PAGER=""

REGION="${1:-${AWS_REGION:-ap-northeast-1}}"; export AWS_REGION="$REGION"

### Secrets Manager Report（値は取得しない）
echo ""
echo "| 名前 | 作成日 | KMS暗号化 | 自動ローテーション | ローテーション最終日 | 次回ローテーション | 最終アクセス日 | タグ | 備考 |"
echo "|------|--------|-----------|--------------------|--------------------|------------------|----------------|------|------|"

NEXT=""
while : ; do
  if [ -n "$NEXT" ]; then
    PAGE="$(aws secretsmanager list-secrets --region "$REGION" --max-results 100 --starting-token "$NEXT" --output json)"
  else
    PAGE="$(aws secretsmanager list-secrets --region "$REGION" --max-results 100 --output json)"
  fi

  while IFS= read -r NAME; do
    [ -z "$NAME" ] && continue
    SEC="$(aws secretsmanager describe-secret --secret-id "$NAME" --region "$REGION" --output json)"
    CR="$(echo "$SEC" | jq -r '.CreatedDate // "-"')"
    KID="$(echo "$SEC" | jq -r '.KmsKeyId // ""')"; KMS="${KID:-default (aws/secretsmanager)}"
    ROT_E="$(echo "$SEC" | jq -r '.RotationEnabled // false')"
    LR="$(echo "$SEC" | jq -r '.LastRotatedDate // "-"')"
    NR="$(echo "$SEC" | jq -r '.NextRotationDate // "-"')"
    LA="$(echo "$SEC" | jq -r '.LastAccessedDate // "-"')"
    TAGS="$(echo "$SEC" | jq -r '[.Tags[]? | "\(.Key)=\(.Value)"] | join(", ")')"
    ROT_ICON="$([ "$ROT_E" = "true" ] && echo "✅" || echo "❌")"
    echo "| $NAME | $CR | $KMS | $ROT_ICON | $LR | $NR | $LA | ${TAGS:-} | |"
  done < <(echo "$PAGE" | jq -r '.SecretList[]?.Name')

  NEXT="$(echo "$PAGE" | jq -r '.NextToken // empty')"
  [ -z "$NEXT" ] && break
done

### SSM SecureString Report（値は取得しない）
echo ""
echo "| 名前 | タイプ | 作成日 | KMS暗号化 | 最終変更日 | タグ | 備考 |"
echo "|------|--------|--------|-----------|------------|------|------|"

NEXT=""
while : ; do
  if [ -n "$NEXT" ]; then
    PAGE="$(aws ssm describe-parameters --region "$REGION" --max-items 50 --starting-token "$NEXT" --output json)"
  else
    PAGE="$(aws ssm describe-parameters --region "$REGION" --max-items 50 --output json)"
  fi

  echo "$PAGE" | jq -r '.Parameters[]? | select(.Type=="SecureString") | [.Name,.Type, (.LastModifiedDate//""), (.KeyId//"")] | @tsv' \
  | while IFS=$'\t' read -r NAME TYPE LMOD KEYID; do
      KMS="${KEYID:-alias/aws/ssm}"
      # 作成日はメタでは取得不可。タグに入れている場合のみ拾う（無ければ "-")
      TAGS_JSON="$(aws ssm list-tags-for-resource --resource-type Parameter --resource-id "$NAME" --region "$REGION" --output json)"
      TAGS_STR="$(echo "$TAGS_JSON" | jq -r '[.Tags[]? | "\(.Key)=\(.Value)"] | join(", ")')"
      CREATED="$(echo "$TAGS_JSON" | jq -r '.Tags[]? | select(.Key=="CreatedDate") | .Value' || true)"
      [ -z "${CREATED:-}" ] && CREATED="-"
      echo "| $NAME | $TYPE | $CREATED | $KMS | ${LMOD:-} | ${TAGS_STR:-} | |"
    done

  NEXT="$(echo "$PAGE" | jq -r '.NextToken // empty')"
  [ -z "$NEXT" ] && break
done

# 実行ログ（1回だけ）
echo "$(date +%F) | D04 実行完了 ($REGION)" >> evidence_execution_log.m
