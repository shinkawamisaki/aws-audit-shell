#!/bin/bash
# D03_ssm_parameter_report_markdown.sh（値は取得しない版）
set -euo pipefail
export AWS_PAGER=""

REGION="${1:-${AWS_REGION:-ap-northeast-1}}"; export AWS_REGION="$REGION"

# Markdownヘッダー（元と同じ列構成：最後に「備考」を残す）
echo "| 名前 | タイプ | 最終変更日 | KMS暗号化キー | タグ | 機密の可能性 | 備考 |"
echo "|------|--------|------------|----------------|------|----------------|------|"

NEXT=""
while : ; do
  if [ -n "$NEXT" ]; then
    PAGE="$(aws ssm describe-parameters --region "$REGION" --max-items 50 --starting-token "$NEXT" --output json)"
  else
    PAGE="$(aws ssm describe-parameters --region "$REGION" --max-items 50 --output json)"
  fi

  echo "$PAGE" | jq -r '.Parameters[]? | [.Name,.Type, (.LastModifiedDate//""), (.KeyId//"")] | @tsv' \
  | while IFS=$'\t' read -r NAME TYPE LMOD KEYID; do
      # SecureString のとき KMS列を埋める（KeyIdが空なら既定alias表記）
      KMS="$([ "$TYPE" = "SecureString" ] && echo "${KEYID:-alias/aws/ssm}" || echo "-")"

      # タグ文字列化
      TAGS="$(aws ssm list-tags-for-resource --region "$REGION" --resource-type Parameter --resource-id "$NAME" --output json \
             | jq -r '[.Tags[]? | "\(.Key)=\(.Value)"] | join(", ")')"

      # 機密フラグ：SecureStringは🔒、名前にsecret等を含めば⚠️
      SECRET_FLAG=""
      if [ "$TYPE" = "SecureString" ]; then
        SECRET_FLAG="🔒"
      elif echo "$NAME" | grep -qiE '(secret|token|password|api[_-]?key|private[_-]?key)'; then
        SECRET_FLAG="⚠️"
      fi

      echo "| $NAME | $TYPE | ${LMOD:-} | $KMS | ${TAGS:-} | $SECRET_FLAG | |"
    done

  NEXT="$(echo "$PAGE" | jq -r '.NextToken // empty')"
  [ -z "$NEXT" ] && break
done

# 実行ログ（1回だけ）
echo "$(date +%F) | D03 実行完了 ($REGION)" >> evidence_execution_log.md
