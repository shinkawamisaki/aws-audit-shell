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

### 🔐 A: IAM・認可・認証
- IAMユーザー一覧
- IAMユーザーグループ & ポリシー
- IAMロール一覧（信頼ポリシー含む）
- IAMカスタムポリシー一覧
- MFAデバイス設定状況
- アクセスキー最終使用日

### 🔎 B: ログ・可観測性・監査証跡
- CloudTrail設定
- AWS Config有効状況
- CloudWatchアラーム一覧
- GuardDuty検出結果
- Inspector Findings

### ☁️ C: インフラ構成
- EC2インスタンス一覧
- Lambda関数一覧
- ECSサービス/タスク定義
- VPC / Subnet / IGW / NATGW
- Security Groupルール一覧
- RDSインスタンス一覧
- LoadBalancer構成（ALB/ELB）
- AutoScaling Group設定
- タグ付きリソース一覧 

### 💾 D: ストレージ / データ管理
- S3バケット一覧
- S3暗号化 / 公開ブロック設定
- SSMパラメータ一覧
- Secrets Manager / SSM Secrets一覧

### 📦 E: CI/CD・メッセージング
- SES設定
- CodePipeline構成
- CodeBuild履歴・定義
- SNSトピック通知設定
- EventBridgeルール一覧
---

## ライセンス

MIT License