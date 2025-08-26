# AWS監査 Evidence Hub

---

## 0. ポリシー（原則）

1. 最小権限：IAMはロールベース、個人に直付け禁止
2. 可観測性：CloudTrail全リージョン・S3ログ化・検証ON
3. 鍵・シークレット：Secrets Manager移行＋Rotation必須
4. 変更管理：チケット＋承認＋検証→デプロイ→レビュー
5. インシデント：72h一次報告、14日以内最終報告

---

## 1. 進捗チェック表（A〜Eコード管理）

---

## 🔐 A: IAM・認可・認証

| ID | 項目 | スクリプト | 状態 | 備考 |
| --- | --- | --- | --- | --- |
| A01 | IAMユーザー一覧 | A01_iam_user_report_markdown.sh | 🆕 |  |
| A02 | IAMユーザーグループ & ポリシー | A02_iam_user_group_policy_report_markdown.sh | 🆕 |  |
| A03 | IAMロール一覧（信頼ポリシー含む） | A03_iam_role_report_markdown.sh | 🆕 |  |
| A04 | IAMカスタムポリシー一覧 | A04_iam_policy_report_markdown.sh | 🆕 |  |
| A05 | MFAデバイス設定状況 | A05_mfa_device_report_markdown.sh | 🆕 |  |
| A06 | アクセスキー最終使用日 | A06_access_key_usage_report_markdown.sh | 🆕 |  |

---

## 🔎 B: ログ・可観測性・監査証跡

| ID | 項目 | スクリプト | 状態 | 備考 |
| --- | --- | --- | --- | --- |
| B01 | CloudTrail設定 | B01_cloudtrail_report_markdown.sh | 🆕 |  |
| B02 | AWS Config有効状況 | B02_config_status_report_markdown.sh | 🆕 |  |
| B03 | CloudWatchアラーム一覧 | B03_cloudwatch_alarm_report_markdown.sh | 🆕 |  |
| B04 | GuardDuty検出結果 | B04_guardduty_finding_report_markdown.sh | 🆕 |  |
| B05 | Inspector Findings | B05_inspector_report.sh | 🟡 | 任意 |

---

## ☁️ C: インフラ構成

| ID | 項目 | スクリプト | 状態 | 備考 |
| --- | --- | --- | --- | --- |
| C01 | EC2インスタンス一覧 | C01_ec2_instance_report_markdown.sh | 🆕 |  |
| C02 | Lambda関数一覧 | C02_lambda_report_markdown.sh | 🆕 |  |
| C03 | ECSサービス/タスク定義 | C03_ecs_service_report_markdown.sh | 🆕 |  |
| C04 | VPC / Subnet / IGW / NATGW | C04_vpc_report_markdown.sh | 🆕 |  |
| C05 | Security Groupルール一覧 | C05_security_group_report_markdown.sh | 🆕 |  |
| C06 | RDSインスタンス一覧 | C06_rds_report_markdown.sh | 🟡 | 任意 |
| C07 | LoadBalancer構成（ALB/ELB） | C07_elb_report_markdown.sh | 🟡 | 任意 |
| C08 | AutoScaling Group設定 | C08_autoscaling_group_report.sh | 🟡 | 任意 |
| C09 | タグ付きリソース一覧 | C09_tagging_report_markdown.sh | 🆕 |  |

---

## 💾 D: ストレージ / データ管理

| ID | 項目 | スクリプト | 状態 | 備考 |
| --- | --- | --- | --- | --- |
| D01 | S3バケット一覧 | D01_s3_bucket_report_markdown.sh | 🆕 |  |
| D02 | S3暗号化 / 公開ブロック設定 | D02_s3_encryption_blockpublic_report.sh | 🆕 |  |
| D03 | SSMパラメータ一覧 | D03_ssm_parameter_report_markdown.sh | 🆕 |  |
| D04 | Secrets Manager / SSM Secrets一覧 | D04_secrets_ssm_report_markdown.sh | 🆕 |  |

---

## 📦 E: CI/CD・メッセージング

| ID | 項目 | スクリプト | 状態 | 備考 |
| --- | --- | --- | --- | --- |
| E01 | SES設定 | E01_ses_report_markdown.sh | 🆕 |  |
| E02 | CodePipeline構成 | E02_codepipeline_report.sh | 🟡 | 任意 |
| E03 | CodeBuild履歴・定義 | E03_codebuild_report.sh | 🟡 | 任意 |
| E04 | SNSトピック通知設定 | E04_sns_topic_report.sh | 🟡 | 任意 |
| E05 | EventBridgeルール一覧 | E05_eventbridge_rule_report.sh | 🟡 | 任意 |

---

## 判定ルール

- 🆕 = 未対応（監査必須 → 優先対応）
- 🟡 = 任意（サービス利用していれば対応）