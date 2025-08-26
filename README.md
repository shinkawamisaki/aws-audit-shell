# AWS監査用シェルスクリプト集

このリポジトリは、AWSアカウントのセキュリティ監査・構成確認を **Markdown形式で Notion に貼り付け可能な形** で出力するシェルスクリプト集です。

📦 スクリプト配布元: [shinkawamisaki/aws-audit-shell](https://github.com/shinkawamisaki/aws-audit-shell)

---

## 使い方

1. ターミナルで対象スクリプトを実行可能にする:

```bash
chmod +x A01_iam_user_report_markdown.sh
```

2. スクリプトを実行して出力をコピー:

```bash
./A01_iam_user_report_markdown.sh | pbcopy
```

3. Notion や Markdown エディタにそのまま貼り付け

---

## スクリプト一覧（カテゴリ別）

### A: IAM・認可・認証
- A01_iam_user_report_markdown.sh
- A02_iam_user_group_policy_report_markdown.sh
- A03_iam_role_report_markdown.sh
- A04_iam_policy_report_markdown.sh
- A05_mfa_device_report_markdown.sh
- A06_access_key_usage_report_markdown.sh

### B: ログ・可観測性・監査証跡
- B01_cloudtrail_report_markdown.sh
- B02_config_status_report_markdown.sh
- B03_cloudwatch_alarm_report_markdown.sh
- B04_guardduty_finding_report_markdown.sh
- B05_inspector_report.sh

### C: インフラ構成
- C01_ec2_instance_report_markdown.sh
- C02_lambda_report_markdown.sh
- C03_ecs_service_report_markdown.sh
- C04_vpc_report_markdown.sh
- C05_security_group_report_markdown.sh
- C06_rds_report_markdown.sh
- C07_elb_report_markdown.sh
- C08_autoscaling_group_report.sh
- C09_tagging_report_markdown.sh

### D: ストレージ / データ管理
- D01_s3_bucket_report_markdown.sh
- D02_s3_encryption_blockpublic_report.sh
- D03_ssm_parameter_report_markdown.sh
- D04_secrets_ssm_report_markdown.sh

### E: CI/CD・メッセージング
- E01_ses_report_markdown.sh
- E02_codepipeline_report.sh
- E03_codebuild_report.sh
- E04_sns_topic_report.sh
- E05_eventbridge_rule_report.sh

---

## ライセンス

MIT License