# 契約ライフサイクル管理システム（CLM） DBスキーマ設計メモ

## 利用ツール
- エディター：Cursor
- スキーマ定義：dbdiagram.io
- バージョン管理：git (GitHub)
- 実行環境：WSL2 (Ubuntu 22.04.4)／MySQL 8.0.39
- GUIクライアント：A5:SQL Mk-2

## 全テナント共通
### マルチテナント対応
```
tenants
```
利用テナントごとにサブドメインを発行し、アプリケーション側ではサブドメインからテナントを特定する設計とした。  
データ分離設計としては共有データベース・共有スキーマモデル（プールモデル）を採用しており、それに伴いテナント単位テーブルには一律 `tenant_id` カラムを具備している。以下のようなメリットを考慮した。

- テナント増加時にデータベースの追加と個別マイグレーション処理が不要となり運用効率が向上
- データベースリソースが抑えられコスト効率が向上

一方で、以下のようなリスクと対策を考慮する必要がある：

- データ分離の確実性：テナント間のデータ侵害
  - 対策例：`gem acts_as_tenant` の利用やミドルウェアなど、アプリケーション層によるテナントスコープ自動適用制御（MySQLではRLS未実装のため）
- パフォーマンス：大規模テナントの影響でレコード数が増加し、他テナントアクセス時のパフォーマンスが低下
  - 対策例：インデックス設計、ヒント句などクエリの最適化

今回の設計ではリスク対策により実運用が成立すると判断し、プールモデルの採用に踏み切った。  

### システム共通マスター情報
```
contract_document_processing_statuses
contract_categories
project_statuses
project_event_types
project_assignment_types
```
各プロダクトテーブルから参照される、列挙型に該当する値を保持するテーブル。  
Enum型での定義ではなくテーブルとして保持し外部テーブルからID参照する設計とした。理由は下記の通り。  
- 新しい値を追加する際にスキーマ変更が不要
- 値の変更や削除が容易
- 複数テーブルからの共通参照時に整合性を保ちやすい
- 多言語対応が容易（後から各テーブルへカラム追加等）
- 検索クエリのパフォーマンス向上
- フロントエンドで選択肢表示する際に取得が容易（DB以外の場所での別途プロパティ定義が不要）

定義する値としては以下のようなパターンを想定。DMLとなるため提出用DDLからは除外した。
```
INSERT INTO `contract_document_processing_statuses` (`name`, `description`) VALUES
('before_analysis', '解析前'),
('analyzing', '解析中'),
('analysis_success', '解析成功'),
('analysis_failure', '解析失敗');

INSERT INTO `contract_categories` (`name`, `description`) VALUES
('業務委託契約', '特定の業務やサービスの提供を外部に委託する際に締結する契約'),
('取引基本契約', '継続的な取引関係における基本的な条件を定める契約'),
('秘密保持契約', '機密情報の取り扱いや保護に関する合意を定める契約'),
('売買契約', '商品やサービスの売買に関する条件を定める契約'),
('賃貸借契約', '不動産や設備などの賃貸に関する条件を定める契約'),
('雇用契約', '雇用者と被雇用者の間で締結される労働条件を定める契約'),
('ライセンス契約', '知的財産権の使用許諾に関する条件を定める契約');

INSERT INTO `project_statuses` (`name`, `description`) VALUES
('to_do', '未着手'),
('in_progress', '進行中'),
('in_review', 'レビュー中'),
('closed_as_completed', '終了（成功）'),
('closed_as_rejected', '終了（却下）');

INSERT INTO `project_assignment_types` (`name`, `description`) VALUES
('assignee', '担当者'),
('requester', '依頼者'),
('participant', '関係者');

INSERT INTO `project_event_types` (`name`, `description`) VALUES
('open', '案件オープン'),
('open_with_attachments', '添付ファイル付き案件オープン'),
('upload_as_draft', 'ドラフト版をアップロード'),
('upload_as_fixed', '締結版をアップロード'),
('comment', 'コメント'),
('comment_with_attachments', '添付ファイル付きコメント'),
('mail', 'メール受信'),
('change_status', '案件ステータス変更');
```


## テナント単位 共通マスター情報
```
users
```
認証とユーザー管理。`gem devise`の利用を想定。SaaSとして最低限必要な機能として以下のモジュール利用とした。
- `Database Authenticatable`
- `Recoverable`

```
departments
```
画面表示に必要な項目のみに限定。もし階層管理が必要となった場合は `gem ancestry` の利用を想定。

```
counterparties
```
自社も含めた契約書の当事者を「取引先」とみなして一括管理する設計とした。  
`is_self`が`true`のレコードはテナント単位でユニークとなるような制約を定義するのが安全であるが、  
少なくともMySQLでは制約定義が煩雑となるようである。（制約のためのカラム追加が必要らしい）  
よって実運用では制約定義を断念し、
```
SELECT tenant_id, COUNT(*) as self_count 
FROM counterparties 
WHERE is_self = true 
GROUP BY tenant_id 
HAVING self_count > 1;
```
のようなクエリを用いた監視スクリプトを適用し、システム運用の中で対応するのが現実的と判断。

## テナント単位 契約DB
```
contract_documents
contract_document_counterparties
contract_document_categories
contract_document_articles
```
`contract_documents` を中心に、1対N関係を表現するサブテーブルを設計した。以下補足を列挙。  

- 文書の登録経路は案件管理経由のみであると判断。よって文書1件に対して1件の案件が定まると想定。 → `contract_documents.project_id`
- ★契約書の当事者は二者とは限らないと判断。 → `contract_document_counterparties`
- ★契約書の担当者は複数とはならないと判断。 → `contract_documents.assignee_user_id`
- 契約書の取引金額について、画面表示項目として存在しないことから税関連などのパターン考慮は除外した。
- 契約書の取引金額について、日本円以外の考慮が不要であることはQA確認済み。
- 契約書の取引金額について、1兆円未満までを小数点2位まで考慮。
- `contract_documents.body` はTEXT型上限65,535バイトを超える可能性があるためLONGTEXT型で定義。
- 条項リストについては、画面では「条」のみの表示であったため `contract_document_articles` のみ用意。項以降が必要の場合は `contract_document_paragraphs`, `contract_document_items` 等を追加する想定。

## テナント単位 案件管理
```
projects
project_assignments
project_events
project_event_attachments
```
`projects` を中心に、1対N関係を表現するサブテーブルを設計した。以下補足を列挙。  

- 依頼者・担当者・関係者はそれぞれに専用のテーブルを用意するかどうか迷ったが、それぞれへの案件との1対Nの関係を表現するのには一つのテーブルで事足りると判断し `project_assignments` のみとした
- 役割の種別が増減する際は `project_assignment_types` へのDML実行で済むため、サービス影響可能性のあるALTER等のDDL実行を回避できる。
- 案件の起票、コメント、メール受信、ファイルアップロードをひっくるめて「イベント」と捉え、 `project_events` として1対N関係を表現した。
- ファイルの添付情報の管理方針については、起票時添付、案件へのダイレクトアップロード、コメントへの添付といった複数パターンの考慮に悩んだが、すべての経路を「イベント」として捉えることで添付情報も「イベントに対する添付」としてイベントとの1対N関係として整理することができた。
- 画面例にはなかったが、「未着手」などのステータス変更もイベントとしてタイムライン表示されると仮説を立て、`project_event_types` で考慮。
