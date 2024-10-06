CREATE TABLE `tenants` (
  `id` SERIAL PRIMARY KEY COMMENT '一意識別子',
  `name` VARCHAR(255) NOT NULL COMMENT 'テナント名',
  `subdomain` VARCHAR(63) NOT NULL UNIQUE COMMENT 'テナント固有のサブドメイン',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時'
) COMMENT = 'テナント';

CREATE TABLE `users` (
  `id` SERIAL PRIMARY KEY COMMENT '一意識別子',
  `tenant_id` BIGINT UNSIGNED NOT NULL COMMENT '所属テナントID',
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
  `tenant_id` BIGINT UNSIGNED NOT NULL COMMENT '所属テナントID',
  `name` VARCHAR(255) NOT NULL COMMENT '部署名称',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時'
) COMMENT = '部署';

CREATE TABLE `counterparties` (
  `id` SERIAL PRIMARY KEY COMMENT '取引先ID',
  `tenant_id` BIGINT UNSIGNED NOT NULL COMMENT '所属テナントID',
  `company_code` VARCHAR(31) NOT NULL COMMENT '企業コード',
  `official_name` VARCHAR(255) NOT NULL COMMENT '企業名（正式名称）',
  `trade_name` VARCHAR(255) COMMENT '企業名（商号）',
  `is_self` BOOLEAN NOT NULL DEFAULT false COMMENT '自社フラグ',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時'
) COMMENT = '取引先';

CREATE TABLE `document_categories` (
  `id` SERIAL PRIMARY KEY COMMENT '文書分類ID',
  `tenant_id` BIGINT UNSIGNED NOT NULL COMMENT '所属テナントID',
  `name` VARCHAR(255) NOT NULL COMMENT '分類名称',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時'
) COMMENT = '文書分類';

CREATE TABLE `contract_documents` (
  `id` SERIAL PRIMARY KEY COMMENT '契約書ID',
  `tenant_id` BIGINT UNSIGNED NOT NULL COMMENT '所属テナントID',
  `project_id` BIGINT UNSIGNED NOT NULL COMMENT '案件ID',
  `counterparty_id` BIGINT UNSIGNED COMMENT '取引先ID',
  `file_name` VARCHAR(255) NOT NULL COMMENT 'ファイル名',
  `file_path` VARCHAR(255) NOT NULL COMMENT 'サーバー上のファイルパス',
  `is_fixed` BOOLEAN NOT NULL DEFAULT false COMMENT '締結版フラグ',
  `processing_status` ENUM ('before_analysis', 'analyzing', 'analysis_success', 'analysis_failure') NOT NULL DEFAULT 'before_analysis' COMMENT '処理ステータス',
  `analysis_completed_at` DATETIME COMMENT '解析完了日時',
  `assignee_user_id` BIGINT UNSIGNED COMMENT '契約書担当ユーザーID',
  `contract_start_date` DATE COMMENT '契約開始日',
  `contract_end_date` DATE COMMENT '契約終了日',
  `contract_amount` DECIMAL(15,2) COMMENT '契約金額',
  `contract_fixed_date` DATE COMMENT '契約締結日',
  `deleted_at` DATETIME COMMENT '削除日時',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時'
) COMMENT = '契約書';

CREATE TABLE `contract_document_categories` (
  `id` SERIAL PRIMARY KEY COMMENT '契約書と文書分類の組み合わせID',
  `tenant_id` BIGINT UNSIGNED NOT NULL COMMENT '所属テナントID',
  `contract_document_id` BIGINT UNSIGNED NOT NULL COMMENT '契約書ID',
  `document_category_id` BIGINT UNSIGNED NOT NULL COMMENT '契約書分類ID',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時'
) COMMENT = '契約書と文書分類の組み合わせ';

CREATE TABLE `contract_document_articles` (
  `id` SERIAL PRIMARY KEY COMMENT '条ID',
  `tenant_id` BIGINT UNSIGNED NOT NULL COMMENT '所属テナントID',
  `contract_document_id` BIGINT UNSIGNED NOT NULL COMMENT '契約書ID',
  `number` BIGINT NOT NULL COMMENT '条番号',
  `title` VARCHAR(255) NOT NULL COMMENT '条タイトル',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時'
) COMMENT = '契約書条項の条部';

CREATE TABLE `projects` (
  `id` SERIAL PRIMARY KEY COMMENT '案件ID',
  `tenant_id` BIGINT UNSIGNED NOT NULL COMMENT '所属テナントID',
  `counterparty_id` BIGINT UNSIGNED NOT NULL COMMENT '取引先ID',
  `name` VARCHAR(255) NOT NULL COMMENT '案件名称',
  `status` ENUM ('to_do', 'in_progress', 'in_review', 'closed_as_completed', 'closed_as_rejected') NOT NULL DEFAULT 'to_do' COMMENT '案件状況',
  `description` TEXT COMMENT '案件概要',
  `email` VARCHAR(255) COMMENT '案件のメールアドレス',
  `start_datetime` DATETIME COMMENT '開始日時',
  `end_datetime` DATETIME COMMENT '終了日時',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時'
) COMMENT = '案件';

CREATE TABLE `project_users` (
  `id` SERIAL PRIMARY KEY COMMENT '案件ユーザーID',
  `tenant_id` BIGINT UNSIGNED NOT NULL COMMENT '所属テナントID',
  `project_id` BIGINT UNSIGNED NOT NULL COMMENT '案件ID',
  `user_id` BIGINT UNSIGNED NOT NULL COMMENT 'ユーザーID',
  `role` ENUM ('assignee', 'requester', 'participant') NOT NULL COMMENT '役割種別',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時'
) COMMENT = '案件ユーザー';

CREATE TABLE `project_events` (
  `id` SERIAL PRIMARY KEY COMMENT '案件イベントID',
  `tenant_id` BIGINT UNSIGNED NOT NULL COMMENT '所属テナントID',
  `project_id` BIGINT UNSIGNED NOT NULL COMMENT '案件ID',
  `created_by` BIGINT UNSIGNED NOT NULL COMMENT '作成者ユーザーID',
  `type` ENUM ('open', 'open_with_attachements', 'upload_as_draft', 'upload_as_fixed', 'comment', 'comment_with_attachements', 'mail', 'change_status') NOT NULL COMMENT '案件イベント種別',
  `comment_body` TEXT COMMENT 'コメント内容',
  `mail_body` TEXT COMMENT 'メール内容',
  `old_status` ENUM ('to_do', 'in_progress', 'in_review', 'closed_as_completed', 'closed_as_rejected') COMMENT '案件状況（変更前）',
  `new_status` ENUM ('to_do', 'in_progress', 'in_review', 'closed_as_completed', 'closed_as_rejected') COMMENT '案件状況（変更後）',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時'
) COMMENT = '案件イベント';

CREATE TABLE `project_event_attachements` (
  `id` SERIAL PRIMARY KEY COMMENT '案件イベント添付ID',
  `tenant_id` BIGINT UNSIGNED NOT NULL COMMENT '所属テナントID',
  `project_event_id` BIGINT UNSIGNED NOT NULL COMMENT '案件イベントID',
  `contract_document_id` BIGINT UNSIGNED COMMENT 'アップロードされた契約書ID',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時'
) COMMENT = '案件イベント添付';

-- インデックスの作成
CREATE UNIQUE INDEX `contract_document_categories_index_0` ON `contract_document_categories` (`contract_document_id`, `document_category_id`);
CREATE UNIQUE INDEX `contract_document_articles_index_1` ON `contract_document_articles` (`contract_document_id`, `number`);
CREATE UNIQUE INDEX `project_users_index_2` ON `project_users` (`project_id`, `user_id`, `role`);
CREATE UNIQUE INDEX `project_event_attachements_index_3` ON `project_event_attachements` (`project_event_id`, `contract_document_id`);

-- 外部キー制約の追加
ALTER TABLE `users` ADD FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE;
ALTER TABLE `users` ADD FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`);
ALTER TABLE `departments` ADD FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE;
ALTER TABLE `counterparties` ADD FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE;
ALTER TABLE `document_categories` ADD FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE;
ALTER TABLE `contract_documents` ADD FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE;
ALTER TABLE `contract_documents` ADD FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`);
ALTER TABLE `contract_documents` ADD FOREIGN KEY (`counterparty_id`) REFERENCES `counterparties` (`id`);
ALTER TABLE `contract_documents` ADD FOREIGN KEY (`assignee_user_id`) REFERENCES `users` (`id`);
ALTER TABLE `contract_document_categories` ADD FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE;
ALTER TABLE `contract_document_categories` ADD FOREIGN KEY (`contract_document_id`) REFERENCES `contract_documents` (`id`);
ALTER TABLE `contract_document_categories` ADD FOREIGN KEY (`document_category_id`) REFERENCES `document_categories` (`id`);
ALTER TABLE `contract_document_articles` ADD FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE;
ALTER TABLE `contract_document_articles` ADD FOREIGN KEY (`contract_document_id`) REFERENCES `contract_documents` (`id`);
ALTER TABLE `projects` ADD FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE;
ALTER TABLE `projects` ADD FOREIGN KEY (`counterparty_id`) REFERENCES `counterparties` (`id`);
ALTER TABLE `project_users` ADD FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE;
ALTER TABLE `project_users` ADD FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`);
ALTER TABLE `project_users` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);
ALTER TABLE `project_events` ADD FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE;
ALTER TABLE `project_events` ADD FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`);
ALTER TABLE `project_events` ADD FOREIGN KEY (`created_by`) REFERENCES `users` (`id`);
ALTER TABLE `project_event_attachements` ADD FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE;
ALTER TABLE `project_event_attachements` ADD FOREIGN KEY (`project_event_id`) REFERENCES `project_events` (`id`);
ALTER TABLE `project_event_attachements` ADD FOREIGN KEY (`contract_document_id`) REFERENCES `contract_documents` (`id`);
