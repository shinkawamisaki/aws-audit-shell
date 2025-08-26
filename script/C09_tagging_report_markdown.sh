#!/bin/bash
# C09_tagging_report_markdown.sh
# AWSリソースのタグ一覧をMarkdown表で出力（監査用）

REGION="ap-northeast-1"

# マークダウンのヘッダー
echo "| ResourceARN | TagKey | TagValue |"
echo "|-------------|--------|----------|"

aws resourcegroupstaggingapi get-resources --region $REGION --output json \
  | jq -r '
    .ResourceTagMappingList[]
    | .ResourceARN as $arn
    | if (.Tags | length) > 0 then
        .Tags[] | "| " + $arn + " | " + .Key + " | " + .Value + " |"
      else
        "| " + $arn + " | - | - |"
      end
  '

# 実行ログに追記（進捗表更新用）
echo "$(date +%F) | C09 実行完了" >> evidence_execution_log.md
