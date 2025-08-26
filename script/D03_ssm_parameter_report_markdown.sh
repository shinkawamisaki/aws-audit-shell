#!/bin/bash
# D03_ssm_parameter_report_markdown.sh

REGION="ap-northeast-1"

# ヘッダー出力（Markdown）
echo "| 名前 | タイプ | 最終変更日 | KMS暗号化キー | タグ | 機密の可能性 | 備考 |"
echo "|------|--------|-------------|----------------|------|----------------|------|"

# パラメータ一覧取得
PARAM_NAMES=$(aws ssm describe-parameters --region "$REGION" \
  --query 'Parameters[*].Name' --output text)

for NAME in $PARAM_NAMES; do
  PARAM=$(aws ssm describe-parameters --region "$REGION" \
    --parameter-filters "Key=Name,Values=$NAME" \
    --query 'Parameters[0]' --output json)

  TYPE=$(echo "$PARAM" | jq -r '.Type')
  LASTMOD=$(echo "$PARAM" | jq -r '.LastModifiedDate')
  KMS=$(echo "$PARAM" | jq -r '.KeyId // "default (aws/ssm)"')

  TAGS=$(aws ssm list-tags-for-resource --resource-type "Parameter" \
    --resource-id "$NAME" --region "$REGION" \
    | jq -r '[.Tags[]? | "\(.Key)=\(.Value)"] | join(", ")')

  # 値取得（セキュアでも中身は取得しない。チェック用）
  VALUE=$(aws ssm get-parameter --name "$NAME" \
    --with-decryption --region "$REGION" 2>/dev/null \
    | jq -r '.Parameter.Value' || echo "")

  # 機密っぽい文字列含むかを判定
  if echo "$VALUE" | grep -qiE 'secret|token|key|AKIA|password'; then
    SECRET="⚠️"
  else
    SECRET=""
  fi

  echo "| $NAME | $TYPE | $LASTMOD | $KMS | $TAGS | $SECRET | |"
      # 実行ログに追記（進捗表更新用）
  echo "$(date +%F) | D03 実行完了" >> evidence_execution_log.md

done