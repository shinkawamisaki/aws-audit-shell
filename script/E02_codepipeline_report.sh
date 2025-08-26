#!/bin/bash
# E02_codepipeline_report.sh

REGION="ap-northeast-1"

# Markdownヘッダー
echo "| パイプライン名 | 状態 | 作成日 | 最終更新日 | ステージ数 | 備考 |"
echo "|----------------|------|--------|--------------|-------------|------|"

# パイプライン一覧取得
PIPELINES=$(aws codepipeline list-pipelines --region "$REGION" --query 'pipelines[*].name' --output text)

for PIPELINE in $PIPELINES; do
  # 詳細取得
  DETAIL=$(aws codepipeline get-pipeline --name "$PIPELINE" --region "$REGION")
  STATE=$(aws codepipeline get-pipeline-state --name "$PIPELINE" --region "$REGION" \
    | jq -r '.stageStates[].latestExecution.status' | sort | uniq | paste -sd "," -)

  CREATED=$(echo "$DETAIL" | jq -r '.metadata.created')
  UPDATED=$(echo "$DETAIL" | jq -r '.metadata.updated')
  STAGE_COUNT=$(echo "$DETAIL" | jq -r '.pipeline.stages | length')

  echo "| $PIPELINE | $STATE | $CREATED | $UPDATED | $STAGE_COUNT | |"
done

echo "$(date +%F) | E02 実行完了" >> evidence_execution_log.md
