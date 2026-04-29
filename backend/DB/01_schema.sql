-- =========================================================
-- 01_schema.sql
-- ESUN Library Borrowing System
-- Database: Supabase PostgreSQL
-- =========================================================

-- Drop old objects
DROP TABLE IF EXISTS borrowing_record CASCADE;
DROP TABLE IF EXISTS inventory CASCADE;
DROP TABLE IF EXISTS inventory_status CASCADE;
DROP TABLE IF EXISTS book CASCADE;
DROP TABLE IF EXISTS app_user CASCADE;

-- =========================================================
-- User Table
-- 使用者資料表
-- =========================================================
CREATE TABLE app_user (
    user_id BIGSERIAL PRIMARY KEY,
    phone_number VARCHAR(20) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    user_name VARCHAR(100) NOT NULL,
    registration_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_login_time TIMESTAMPTZ NULL,

    CONSTRAINT chk_phone_number_format
        CHECK (phone_number ~ '^09[0-9]{8}$')
);

COMMENT ON TABLE app_user IS '使用者資料表';
COMMENT ON COLUMN app_user.user_id IS '使用者 ID';
COMMENT ON COLUMN app_user.phone_number IS '手機號碼，作為登入帳號';
COMMENT ON COLUMN app_user.password_hash IS '加鹽雜湊後的密碼';
COMMENT ON COLUMN app_user.user_name IS '使用者名稱';
COMMENT ON COLUMN app_user.registration_time IS '註冊時間';
COMMENT ON COLUMN app_user.last_login_time IS '最後登入時間';

-- =========================================================
-- Book Table
-- 書籍主檔
-- 一本書的基本資料只存一次，避免重複資料
-- =========================================================
CREATE TABLE book (
    isbn VARCHAR(20) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    author VARCHAR(100) NOT NULL,
    introduction TEXT
);

COMMENT ON TABLE book IS '書籍主檔';
COMMENT ON COLUMN book.isbn IS '國際標準書號 ISBN';
COMMENT ON COLUMN book.name IS '書名';
COMMENT ON COLUMN book.author IS '作者';
COMMENT ON COLUMN book.introduction IS '書籍簡介';

-- =========================================================
-- Inventory Status Table
-- 庫存狀態代碼表
-- 將狀態獨立成表，提升正規化程度
-- =========================================================
CREATE TABLE inventory_status (
    status_code VARCHAR(30) PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL
);

COMMENT ON TABLE inventory_status IS '庫存狀態代碼表';
COMMENT ON COLUMN inventory_status.status_code IS '狀態代碼';
COMMENT ON COLUMN inventory_status.status_name IS '狀態名稱';

-- =========================================================
-- Inventory Table
-- 實體館藏 / 庫存資料
-- 同一本書可以有多本實體庫存
-- =========================================================
CREATE TABLE inventory (
    inventory_id BIGSERIAL PRIMARY KEY,
    isbn VARCHAR(20) NOT NULL,
    store_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    status_code VARCHAR(30) NOT NULL DEFAULT 'AVAILABLE',

    CONSTRAINT fk_inventory_book
        FOREIGN KEY (isbn)
        REFERENCES book(isbn),

    CONSTRAINT fk_inventory_status
        FOREIGN KEY (status_code)
        REFERENCES inventory_status(status_code)
);

COMMENT ON TABLE inventory IS '庫存資料表，每一筆代表一本實體館藏';
COMMENT ON COLUMN inventory.inventory_id IS '庫存 ID';
COMMENT ON COLUMN inventory.isbn IS '對應書籍 ISBN';
COMMENT ON COLUMN inventory.store_time IS '書籍入庫時間';
COMMENT ON COLUMN inventory.status_code IS '庫存狀態';

-- =========================================================
-- Borrowing Record Table
-- 借閱紀錄
-- 不重複儲存 user_name、book_name、author 等資料
-- 只保存借閱事件本身需要的關聯與時間
-- =========================================================
CREATE TABLE borrowing_record (
    record_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    inventory_id BIGINT NOT NULL,
    borrowing_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    return_time TIMESTAMPTZ NULL,

    CONSTRAINT fk_record_user
        FOREIGN KEY (user_id)
        REFERENCES app_user(user_id),

    CONSTRAINT fk_record_inventory
        FOREIGN KEY (inventory_id)
        REFERENCES inventory(inventory_id),

    CONSTRAINT chk_return_time_after_borrowing_time
        CHECK (
            return_time IS NULL
            OR return_time >= borrowing_time
        )
);

COMMENT ON TABLE borrowing_record IS '借閱紀錄表';
COMMENT ON COLUMN borrowing_record.record_id IS '借閱紀錄 ID';
COMMENT ON COLUMN borrowing_record.user_id IS '借閱者使用者 ID';
COMMENT ON COLUMN borrowing_record.inventory_id IS '被借閱的庫存 ID';
COMMENT ON COLUMN borrowing_record.borrowing_time IS '借出時間';
COMMENT ON COLUMN borrowing_record.return_time IS '歸還時間，NULL 表示尚未歸還';

-- =========================================================
-- Indexes
-- =========================================================
CREATE INDEX idx_user_phone_number
ON app_user(phone_number);

CREATE INDEX idx_inventory_isbn
ON inventory(isbn);

CREATE INDEX idx_inventory_status_code
ON inventory(status_code);

CREATE INDEX idx_record_user_id
ON borrowing_record(user_id);

CREATE INDEX idx_record_inventory_id
ON borrowing_record(inventory_id);

CREATE INDEX idx_record_borrowing_time
ON borrowing_record(borrowing_time);

-- =========================================================
-- Important Data Integrity Rule
-- 同一本實體書在尚未歸還前，只能有一筆未完成借閱紀錄
-- 可防止資料錯亂與重複借閱
-- =========================================================
CREATE UNIQUE INDEX uq_active_borrowing_inventory
ON borrowing_record(inventory_id)
WHERE return_time IS NULL;