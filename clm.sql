-- テナント管理テーブル
-- マルチテナント構造を実現するための基本テーブル
CREATE TABLE `tenants` (
  `id` SERIAL PRIMARY KEY COMMENT 'テナントの一意識別子',
  `name` VARCHAR(255) NOT NULL COMMENT 'テナント名',
  `subdomain` VARCHAR(63) UNIQUE NOT NULL COMMENT 'テナント固有のサブドメイン',
  `is_active` BOOLEAN NOT NULL DEFAULT true COMMENT 'テナントのアクティブ状態',
  `created_at` TIMESTAMP NOT NULL DEFAULT (CURRENT_TIMESTAMP) COMMENT '作成日時',
  `updated_at` TIMESTAMP NOT NULL DEFAULT (CURRENT_TIMESTAMP) COMMENT '更新日時'
);

-- ユーザー管理テーブル
-- Deviseと互換性のあるユーザー認証情報を格納
CREATE TABLE `users` (
  `id` SERIAL PRIMARY KEY COMMENT 'ユーザーの一意識別子',
  `tenant_id` INTEGER NOT NULL COMMENT '所属テナントID',
  `email` VARCHAR(255) NOT NULL COMMENT 'ユーザーのメールアドレス',
  `encrypted_password` VARCHAR(255) NOT NULL COMMENT '暗号化されたパスワード',
  `reset_password_token` VARCHAR(255) COMMENT 'パスワードリセット用トークン',
  `reset_password_sent_at` TIMESTAMP COMMENT 'パスワードリセットトークン送信日時',
  `remember_created_at` TIMESTAMP COMMENT 'Remember Me作成日時',
  `sign_in_count` INTEGER NOT NULL DEFAULT 0 COMMENT 'サインイン回数',
  `current_sign_in_at` TIMESTAMP COMMENT '現在のサインイン日時',
  `last_sign_in_at` TIMESTAMP COMMENT '最終サインイン日時',
  `current_sign_in_ip` VARCHAR(255) COMMENT '現在のサインインIP',
  `last_sign_in_ip` VARCHAR(255) COMMENT '最終サインインIP',
  `confirmation_token` VARCHAR(255) COMMENT 'メール確認用トークン',
  `confirmed_at` TIMESTAMP COMMENT 'メール確認日時',
  `confirmation_sent_at` TIMESTAMP COMMENT '確認メール送信日時',
  `unconfirmed_email` VARCHAR(255) COMMENT '未確認のメールアドレス',
  `failed_attempts` INTEGER NOT NULL DEFAULT 0 COMMENT 'ログイン失敗回数',
  `unlock_token` VARCHAR(255) COMMENT 'アカウントロック解除用トークン',
  `locked_at` TIMESTAMP COMMENT 'アカウントロック日時',
  `first_name` VARCHAR(100) COMMENT 'ユーザーの名',
  `last_name` VARCHAR(100) COMMENT 'ユーザーの姓',
  `is_active` BOOLEAN NOT NULL DEFAULT true COMMENT 'ユーザーのアクティブ状態',
  `created_at` TIMESTAMP NOT NULL DEFAULT (CURRENT_TIMESTAMP) COMMENT '作成日時',
  `updated_at` TIMESTAMP NOT NULL DEFAULT (CURRENT_TIMESTAMP) COMMENT '更新日時'
);

-- ロール（役割）管理テーブル
-- ユーザーの権限を定義するためのロールを管理
CREATE TABLE `roles` (
  `id` SERIAL PRIMARY KEY COMMENT 'ロールの一意識別子',
  `tenant_id` INTEGER NOT NULL COMMENT '所属テナントID',
  `name` VARCHAR(50) NOT NULL COMMENT 'ロール名',
  `description` TEXT COMMENT 'ロールの説明',
  `created_at` TIMESTAMP NOT NULL DEFAULT (CURRENT_TIMESTAMP) COMMENT '作成日時',
  `updated_at` TIMESTAMP NOT NULL DEFAULT (CURRENT_TIMESTAMP) COMMENT '更新日時'
);

-- ユーザーとロールの関連付けテーブル
-- ユーザーに複数のロールを割り当てるための中間テーブル
CREATE TABLE `user_roles` (
  `id` SERIAL PRIMARY KEY COMMENT 'ユーザーロールの一意識別子',
  `tenant_id` INTEGER NOT NULL COMMENT '所属テナントID',
  `user_id` INTEGER NOT NULL COMMENT 'ユーザーID',
  `role_id` INTEGER NOT NULL COMMENT 'ロールID',
  `created_at` TIMESTAMP NOT NULL DEFAULT (CURRENT_TIMESTAMP) COMMENT '作成日時',
  `updated_at` TIMESTAMP NOT NULL DEFAULT (CURRENT_TIMESTAMP) COMMENT '更新日時'
);

-- 契約当事者管理テーブル
-- 契約に関わる企業や個人の情報を管理
CREATE TABLE `contract_parties` (
  `id` SERIAL PRIMARY KEY COMMENT '契約当事者の一意識別子',
  `tenant_id` INTEGER NOT NULL COMMENT '所属テナントID',
  `company_code` VARCHAR(50) COMMENT '会社コード',
  `official_name` VARCHAR(255) NOT NULL COMMENT '正式名称',
  `trade_name` VARCHAR(255) COMMENT '商号',
  `address_id` INTEGER COMMENT '住所ID（将来的に住所テーブルとの関連付けを想定）',
  `contact_person_id` INTEGER COMMENT '連絡先担当者ID（将来的に連絡先テーブルとの関連付けを想定）',
  `created_at` TIMESTAMP NOT NULL DEFAULT (CURRENT_TIMESTAMP) COMMENT '作成日時',
  `updated_at` TIMESTAMP NOT NULL DEFAULT (CURRENT_TIMESTAMP) COMMENT '更新日時'
);

-- 契約書ドキュメント管理テーブル
-- アップロードされた契約書ファイルの基本情報を管理
CREATE TABLE `contract_documents` (
  `id` SERIAL PRIMARY KEY COMMENT '契約書ドキュメントの一意識別子',
  `tenant_id` INTEGER NOT NULL COMMENT '所属テナントID',
  `file_name` VARCHAR(255) NOT NULL COMMENT 'ファイル名',
  `file_path` VARCHAR(255) NOT NULL COMMENT 'ファイルパス',
  `uploaded_date` TIMESTAMP NOT NULL DEFAULT (CURRENT_TIMESTAMP) COMMENT 'アップロード日時',
  `document_type` VARCHAR(50) NOT NULL COMMENT 'ドキュメントタイプ',
  `processing_status` ENUM ('uploaded_before_analysis', 'analyzing', 'analysis_success', 'analysis_failure', 'deleted') NOT NULL COMMENT '処理状態',
  `analysis_completion_date` TIMESTAMP COMMENT '分析完了日時',
  `responsible_user_id` INTEGER NOT NULL COMMENT '担当ユーザーID',
  `document_category` VARCHAR(50) COMMENT 'ドキュメントカテゴリ',
  `contract_start_date` DATE COMMENT '契約開始日',
  `contract_end_date` DATE COMMENT '契約終了日',
  `party_a_id` INTEGER NOT NULL COMMENT '契約当事者AのID',
  `party_b_id` INTEGER NOT NULL COMMENT '契約当事者BのID',
  `transaction_amount` DECIMAL(15,2) COMMENT '取引金額',
  `currency` VARCHAR(3) COMMENT '通貨コード（例：JPY, USD）',
  `created_at` TIMESTAMP NOT NULL DEFAULT (CURRENT_TIMESTAMP) COMMENT '作成日時',
  `updated_at` TIMESTAMP NOT NULL DEFAULT (CURRENT_TIMESTAMP) COMMENT '更新日時'
);

-- 契約書バージョン管理テーブル
-- 契約書の改訂履歴を管理
CREATE TABLE `contract_versions` (
  `id` SERIAL PRIMARY KEY COMMENT '契約書バージョンの一意識別子',
  `tenant_id` INTEGER NOT NULL COMMENT '所属テナントID',
  `contract_document_id` INTEGER NOT NULL COMMENT '関連する契約書ドキュメントID',
  `version_number` INTEGER NOT NULL COMMENT 'バージョン番号',
  `file_name` VARCHAR(255) NOT NULL COMMENT 'ファイル名',
  `file_path` VARCHAR(255) NOT NULL COMMENT 'ファイルパス',
  `created_at` TIMESTAMP NOT NULL DEFAULT (CURRENT_TIMESTAMP) COMMENT '作成日時',
  `created_by` INTEGER NOT NULL COMMENT 'バージョンを作成したユーザーID'
);

-- 契約条項管理テーブル
-- 契約書内の個別条項を管理
CREATE TABLE `contract_clauses` (
  `id` SERIAL PRIMARY KEY COMMENT '契約条項の一意識別子',
  `tenant_id` INTEGER NOT NULL COMMENT '所属テナントID',
  `contract_version_id` INTEGER NOT NULL COMMENT '関連する契約書バージョンID',
  `clause_number` VARCHAR(20) NOT NULL COMMENT '条項番号',
  `clause_title` VARCHAR(255) NOT NULL COMMENT '条項タイトル',
  `clause_content` TEXT NOT NULL COMMENT '条項内容',
  `is_key_clause` BOOLEAN NOT NULL DEFAULT false COMMENT '重要条項フラグ'
);

-- 契約書コメント管理テーブル
-- 契約書レビュー時のコメントを管理
CREATE TABLE `contract_comments` (
  `id` SERIAL PRIMARY KEY COMMENT 'コメントの一意識別子',
  `tenant_id` INTEGER NOT NULL COMMENT '所属テナントID',
  `contract_version_id` INTEGER NOT NULL COMMENT '関連する契約書バージョンID',
  `user_id` INTEGER NOT NULL COMMENT 'コメントを作成したユーザーID',
  `comment_text` TEXT NOT NULL COMMENT 'コメント内容',
  `created_at` TIMESTAMP NOT NULL DEFAULT (CURRENT_TIMESTAMP) COMMENT '作成日時'
);

-- 契約書ワークフロー管理テーブル
-- 契約書の承認プロセスを管理
CREATE TABLE `contract_workflows` (
  `id` SERIAL PRIMARY KEY COMMENT 'ワークフローの一意識別子',
  `tenant_id` INTEGER NOT NULL COMMENT '所属テナントID',
  `contract_document_id` INTEGER NOT NULL COMMENT '関連する契約書ドキュメントID',
  `current_status` ENUM ('draft', 'internal_review', 'external_review', 'negotiation', 'approval', 'signed', 'active', 'expired', 'terminated') NOT NULL COMMENT '現在のステータス',
  `current_assignee` INTEGER COMMENT '現在の担当者ID',
  `next_action_date` DATE COMMENT '次のアクション日'
);

-- インデックスの作成
CREATE UNIQUE INDEX `users_index_0` ON `users` (`tenant_id`, `email`);
CREATE UNIQUE INDEX `users_index_1` ON `users` (`reset_password_token`);
CREATE UNIQUE INDEX `users_index_2` ON `users` (`confirmation_token`);
CREATE UNIQUE INDEX `users_index_3` ON `users` (`unlock_token`);
CREATE UNIQUE INDEX `roles_index_4` ON `roles` (`tenant_id`, `name`);
CREATE UNIQUE INDEX `user_roles_index_5` ON `user_roles` (`tenant_id`, `user_id`, `role_id`);
CREATE UNIQUE INDEX `contract_parties_index_6` ON `contract_parties` (`tenant_id`, `company_code`);
CREATE UNIQUE INDEX `contract_versions_index_7` ON `contract_versions` (`tenant_id`, `contract_document_id`, `version_number`);
CREATE UNIQUE INDEX `contract_clauses_index_8` ON `contract_clauses` (`tenant_id`, `contract_version_id`, `clause_number`);

-- 外部キー制約の追加
ALTER TABLE `users` ADD FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`);
ALTER TABLE `roles` ADD FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`);
ALTER TABLE `user_roles` ADD FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`);
ALTER TABLE `contract_parties` ADD FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`);
ALTER TABLE `contract_documents` ADD FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`);
ALTER TABLE `contract_versions` ADD FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`);
ALTER TABLE `contract_clauses` ADD FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`);
ALTER TABLE `contract_comments` ADD FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`);
ALTER TABLE `contract_workflows` ADD FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`);
ALTER TABLE `user_roles` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
ALTER TABLE `user_roles` ADD FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE;
ALTER TABLE `contract_documents` ADD FOREIGN KEY (`party_a_id`) REFERENCES `contract_parties` (`id`);
ALTER TABLE `contract_documents` ADD FOREIGN KEY (`party_b_id`) REFERENCES `contract_parties` (`id`);
ALTER TABLE `contract_documents` ADD FOREIGN KEY (`responsible_user_id`) REFERENCES `users` (`id`);
ALTER TABLE `contract_versions` ADD FOREIGN KEY (`contract_document_id`) REFERENCES `contract_documents` (`id`);
ALTER TABLE `contract_versions` ADD FOREIGN KEY (`created_by`) REFERENCES `users` (`id`);
ALTER TABLE `contract_clauses` ADD FOREIGN KEY (`contract_version_id`) REFERENCES `contract_versions` (`id`);
ALTER TABLE `contract_comments` ADD FOREIGN KEY (`contract_version_id`) REFERENCES `contract_versions` (`id`);
ALTER TABLE `contract_comments` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);
ALTER TABLE `contract_workflows` ADD FOREIGN KEY (`contract_document_id`) REFERENCES `contract_documents` (`id`);
ALTER TABLE `contract_workflows` ADD FOREIGN KEY (`current_assignee`) REFERENCES `users` (`id`);