-- ===========================================================================
-- 全テナント共通
-- ===========================================================================
CREATE TABLE `tenants` (
  `id` MEDIUMINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT '一意識別子',
  `name` VARCHAR(255) NOT NULL COMMENT 'テナント名',
  `subdomain` VARCHAR(63) NOT NULL UNIQUE COMMENT 'テナント固有のサブドメイン',
  `description` TEXT COMMENT 'テナントの説明',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時'
) COMMENT = 'テナント';

CREATE TABLE `contract_document_processing_statuses` (
  `id` TINYINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT '処理ステータスID',
  `name` VARCHAR(50) NOT NULL UNIQUE COMMENT '処理ステータス名',
  `description` TEXT COMMENT '処理ステータスの説明',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時'
) COMMENT = '契約書処理ステータス';

CREATE TABLE `contract_categories` (
  `id` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT '契約分類ID',
  `name` VARCHAR(255) NOT NULL COMMENT '契約分類名称',
  `description` TEXT COMMENT '契約分類の説明',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時'
) COMMENT = '契約分類';

CREATE TABLE `project_statuses` (
  `id` TINYINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT '案件ステータスID',
  `name` VARCHAR(50) NOT NULL UNIQUE COMMENT '案件ステータス名',
  `description` TEXT COMMENT '案件ステータスの説明',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時'
) COMMENT = '案件ステータス';

CREATE TABLE `project_event_types` (
  `id` TINYINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT '案件イベント種別ID',
  `name` VARCHAR(50) NOT NULL UNIQUE COMMENT '案件イベント種別名',
  `description` TEXT COMMENT '案件イベント種別の説明',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時'
) COMMENT = '案件イベント種別';

CREATE TABLE `project_assignment_types` (
  `id` TINYINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT '案件アサイン種別ID',
  `name` VARCHAR(50) NOT NULL UNIQUE COMMENT '案件アサイン種別名',
  `description` TEXT COMMENT '案件アサイン種別の説明',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時'
) COMMENT = '案件アサイン種別';

-- ===========================================================================
-- テナント単位 プロダクト共通
-- ===========================================================================
CREATE TABLE `users` (
  `id` SERIAL PRIMARY KEY COMMENT '一意識別子',
  `tenant_id` MEDIUMINT UNSIGNED NOT NULL COMMENT '所属テナントID',
  `email` VARCHAR(255) NOT NULL UNIQUE COMMENT 'ユーザーのメールアドレス',
  `encrypted_password` VARCHAR(255) NOT NULL COMMENT '暗号化されたパスワード',
  `reset_password_token` VARCHAR(255) UNIQUE COMMENT 'パスワードリセット用トークン',
  `reset_password_sent_at` DATETIME COMMENT 'パスワードリセットトークン送信日時',
  `first_name` VARCHAR(100) COMMENT 'ユーザーの名',
  `last_name` VARCHAR(100) COMMENT 'ユーザーの姓',
  `department_id` BIGINT UNSIGNED NOT NULL COMMENT '所属部署ID',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時'
) COMMENT = 'ユーザー';

CREATE TABLE `departments` (
  `id` SERIAL PRIMARY KEY COMMENT '部署ID',
  `tenant_id` MEDIUMINT UNSIGNED NOT NULL COMMENT '所属テナントID',
  `name` VARCHAR(255) NOT NULL COMMENT '部署名称',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時'
) COMMENT = '部署';

CREATE TABLE `counterparties` (
  `id` SERIAL PRIMARY KEY COMMENT '取引先ID',
  `tenant_id` MEDIUMINT UNSIGNED NOT NULL COMMENT '所属テナントID',
  `company_code` VARCHAR(31) NOT NULL COMMENT '企業コード',
  `official_name` VARCHAR(255) NOT NULL COMMENT '企業名（正式名称）',
  `trade_name` VARCHAR(255) COMMENT '企業名（商号）',
  `is_self` BOOLEAN NOT NULL DEFAULT false COMMENT '自社フラグ',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時'
) COMMENT = '取引先';

-- ===========================================================================
-- 契約DB
-- ===========================================================================
CREATE TABLE `contract_documents` (
  `id` SERIAL PRIMARY KEY COMMENT '契約書ID',
  `tenant_id` MEDIUMINT UNSIGNED NOT NULL COMMENT '所属テナントID',
  `project_id` BIGINT UNSIGNED NOT NULL COMMENT '案件ID',
  `file_name` VARCHAR(255) NOT NULL COMMENT 'ファイル名',
  `file_path` VARCHAR(255) NOT NULL COMMENT 'サーバー上のファイルパス',
  `body` LONGTEXT NOT NULL COMMENT '契約書内容',
  `is_fixed` BOOLEAN NOT NULL DEFAULT false COMMENT '締結版フラグ',
  `processing_status_id` TINYINT UNSIGNED NOT NULL COMMENT '処理ステータスID',
  `analysis_completed_at` DATETIME COMMENT '解析完了日時',
  `contract_start_date` DATE COMMENT '契約開始日',
  `contract_end_date` DATE COMMENT '契約終了日',
  `contract_amount` DECIMAL(15,2) COMMENT '契約金額',
  `contract_fixed_date` DATE COMMENT '契約締結日',
  `deleted_at` DATETIME COMMENT '削除日時',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時'
) COMMENT = '契約書';

CREATE TABLE `contract_document_assignees` (
  `id` SERIAL PRIMARY KEY COMMENT '契約書担当者ID',
  `tenant_id` MEDIUMINT UNSIGNED NOT NULL COMMENT '所属テナントID',
  `contract_document_id` BIGINT UNSIGNED NOT NULL COMMENT '契約書ID',
  `user_id` BIGINT UNSIGNED NOT NULL COMMENT '担当者ユーザーID',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時'
) COMMENT = '契約書担当者';

CREATE TABLE `contract_document_counterparties` (
  `id` SERIAL PRIMARY KEY COMMENT '契約書取引先ID',
  `tenant_id` MEDIUMINT UNSIGNED NOT NULL COMMENT '所属テナントID',
  `contract_document_id` BIGINT UNSIGNED NOT NULL COMMENT '契約書ID',
  `counterparty_id` BIGINT UNSIGNED NOT NULL COMMENT '取引先ID',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時'
) COMMENT = '契約書取引先';

CREATE TABLE `contract_document_categories` (
  `id` SERIAL PRIMARY KEY COMMENT '契約書契約分類ID',
  `tenant_id` MEDIUMINT UNSIGNED NOT NULL COMMENT '所属テナントID',
  `contract_document_id` BIGINT UNSIGNED NOT NULL COMMENT '契約書ID',
  `contract_category_id` SMALLINT UNSIGNED NOT NULL COMMENT '契約分類ID',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時'
) COMMENT = '契約書契約分類';

CREATE TABLE `contract_document_articles` (
  `id` SERIAL PRIMARY KEY COMMENT '条ID',
  `tenant_id` MEDIUMINT UNSIGNED NOT NULL COMMENT '所属テナントID',
  `contract_document_id` BIGINT UNSIGNED NOT NULL COMMENT '契約書ID',
  `number` BIGINT NOT NULL COMMENT '条番号',
  `title` VARCHAR(255) NOT NULL COMMENT '条タイトル',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時'
) COMMENT = '契約書条項の条部';

-- ===========================================================================
-- 案件管理
-- ===========================================================================
CREATE TABLE `projects` (
  `id` SERIAL PRIMARY KEY COMMENT '案件ID',
  `tenant_id` MEDIUMINT UNSIGNED NOT NULL COMMENT '所属テナントID',
  `counterparty_id` BIGINT UNSIGNED NOT NULL COMMENT '取引先ID',
  `name` VARCHAR(255) NOT NULL COMMENT '案件名称',
  `status_id` TINYINT UNSIGNED NOT NULL COMMENT '案件ステータスID',
  `created_by` BIGINT UNSIGNED NOT NULL COMMENT '作成者ユーザーID',
  `description` TEXT COMMENT '案件概要',
  `email` VARCHAR(255) COMMENT '案件のメールアドレス',
  `desired_deadline_date` DATE COMMENT '希望期限',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時'
) COMMENT = '案件';

CREATE TABLE `project_assignments` (
  `id` SERIAL PRIMARY KEY COMMENT '案件アサインID',
  `tenant_id` MEDIUMINT UNSIGNED NOT NULL COMMENT '所属テナントID',
  `project_id` BIGINT UNSIGNED NOT NULL COMMENT '案件ID',
  `user_id` BIGINT UNSIGNED NOT NULL COMMENT 'ユーザーID',
  `type_id` TINYINT UNSIGNED NOT NULL COMMENT '案件アサイン種別ID',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時'
) COMMENT = '案件アサイン';

CREATE TABLE `project_events` (
  `id` SERIAL PRIMARY KEY COMMENT '案件イベントID',
  `tenant_id` MEDIUMINT UNSIGNED NOT NULL COMMENT '所属テナントID',
  `project_id` BIGINT UNSIGNED NOT NULL COMMENT '案件ID',
  `created_by` BIGINT UNSIGNED NOT NULL COMMENT '作成者ユーザーID',
  `type_id` TINYINT UNSIGNED NOT NULL COMMENT '案件イベント種別ID',
  `comment_body` TEXT COMMENT 'コメント内容',
  `mail_body` TEXT COMMENT 'メール内容',
  `old_status_id` TINYINT UNSIGNED COMMENT '案件ステータス（変更前）',
  `new_status_id` TINYINT UNSIGNED COMMENT '案件ステータス（変更後）',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時'
) COMMENT = '案件イベント';

CREATE TABLE `project_event_attachments` (
  `id` SERIAL PRIMARY KEY COMMENT '案件イベント添付ID',
  `tenant_id` MEDIUMINT UNSIGNED NOT NULL COMMENT '所属テナントID',
  `project_event_id` BIGINT UNSIGNED NOT NULL COMMENT '案件イベントID',
  `contract_document_id` BIGINT UNSIGNED COMMENT 'アップロードされた契約書ID',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時'
) COMMENT = '案件イベント添付';

-- ===========================================================================
-- インデックス
-- ===========================================================================
CREATE UNIQUE INDEX `contract_document_assignees_index_0` ON `contract_document_assignees` (`contract_document_id`, `user_id`);
CREATE UNIQUE INDEX `contract_document_counterparties_index_0` ON `contract_document_counterparties` (`contract_document_id`, `counterparty_id`);
CREATE UNIQUE INDEX `contract_document_categories_index_0` ON `contract_document_categories` (`contract_document_id`, `contract_category_id`);
CREATE UNIQUE INDEX `contract_document_articles_index_0` ON `contract_document_articles` (`contract_document_id`, `number`);
CREATE UNIQUE INDEX `project_assignments_index_0` ON `project_assignments` (`project_id`, `user_id`, `type_id`);
CREATE UNIQUE INDEX `project_event_attachments_index_0` ON `project_event_attachments` (`project_event_id`, `contract_document_id`);

-- ===========================================================================
-- 外部キー制約
-- ===========================================================================
ALTER TABLE `users` ADD FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE;
ALTER TABLE `users` ADD FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`);
ALTER TABLE `departments` ADD FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE;
ALTER TABLE `counterparties` ADD FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE;
ALTER TABLE `contract_documents` ADD FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE;
ALTER TABLE `contract_documents` ADD FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`);
ALTER TABLE `contract_documents` ADD FOREIGN KEY (`processing_status_id`) REFERENCES `contract_document_processing_statuses` (`id`);
ALTER TABLE `contract_document_assignees` ADD FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE;
ALTER TABLE `contract_document_assignees` ADD FOREIGN KEY (`contract_document_id`) REFERENCES `contract_documents` (`id`);
ALTER TABLE `contract_document_assignees` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);
ALTER TABLE `contract_document_counterparties` ADD FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE;
ALTER TABLE `contract_document_counterparties` ADD FOREIGN KEY (`contract_document_id`) REFERENCES `contract_documents` (`id`);
ALTER TABLE `contract_document_counterparties` ADD FOREIGN KEY (`counterparty_id`) REFERENCES `counterparties` (`id`);
ALTER TABLE `contract_document_categories` ADD FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE;
ALTER TABLE `contract_document_categories` ADD FOREIGN KEY (`contract_document_id`) REFERENCES `contract_documents` (`id`);
ALTER TABLE `contract_document_categories` ADD FOREIGN KEY (`contract_category_id`) REFERENCES `contract_categories` (`id`);
ALTER TABLE `contract_document_articles` ADD FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE;
ALTER TABLE `contract_document_articles` ADD FOREIGN KEY (`contract_document_id`) REFERENCES `contract_documents` (`id`);
ALTER TABLE `projects` ADD FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE;
ALTER TABLE `projects` ADD FOREIGN KEY (`counterparty_id`) REFERENCES `counterparties` (`id`);
ALTER TABLE `projects` ADD FOREIGN KEY (`status_id`) REFERENCES `project_statuses` (`id`);
ALTER TABLE `project_assignments` ADD FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE;
ALTER TABLE `project_assignments` ADD FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`);
ALTER TABLE `project_assignments` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);
ALTER TABLE `project_assignments` ADD FOREIGN KEY (`type_id`) REFERENCES `project_assignment_types` (`id`);
ALTER TABLE `project_events` ADD FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE;
ALTER TABLE `project_events` ADD FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`);
ALTER TABLE `project_events` ADD FOREIGN KEY (`created_by`) REFERENCES `users` (`id`);
ALTER TABLE `project_events` ADD FOREIGN KEY (`type_id`) REFERENCES `project_event_types` (`id`);
ALTER TABLE `project_events` ADD FOREIGN KEY (`old_status_id`) REFERENCES `project_statuses` (`id`);
ALTER TABLE `project_events` ADD FOREIGN KEY (`new_status_id`) REFERENCES `project_statuses` (`id`);
ALTER TABLE `project_event_attachments` ADD FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE;
ALTER TABLE `project_event_attachments` ADD FOREIGN KEY (`project_event_id`) REFERENCES `project_events` (`id`);
ALTER TABLE `project_event_attachments` ADD FOREIGN KEY (`contract_document_id`) REFERENCES `contract_documents` (`id`);
