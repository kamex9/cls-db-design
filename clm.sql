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
  `department_id` BIGINT NOT NULL COMMENT '所属部署ID'
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
  FOREIGN KEY (`tenant_id`) REFERENCES `tenants`(`id`) ON DELETE CASCADE
) COMMENT = 'ユーザー';
