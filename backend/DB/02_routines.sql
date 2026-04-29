-- =========================================================
-- 02_routines.sql
-- Stored Routines for ESUN Library Borrowing System
-- Database: Supabase PostgreSQL
-- =========================================================

-- Drop old routines
DROP FUNCTION IF EXISTS fn_find_user_by_phone(VARCHAR);
DROP FUNCTION IF EXISTS fn_list_books();
DROP PROCEDURE IF EXISTS sp_register_user(VARCHAR, VARCHAR, VARCHAR);
DROP PROCEDURE IF EXISTS sp_update_last_login(BIGINT);
DROP PROCEDURE IF EXISTS sp_borrow_book(BIGINT, BIGINT);
DROP PROCEDURE IF EXISTS sp_return_book(BIGINT, BIGINT);

-- =========================================================
-- Register User
-- 註冊使用者
-- =========================================================
CREATE OR REPLACE PROCEDURE sp_register_user(
    IN p_phone_number VARCHAR,
    IN p_password_hash VARCHAR,
    IN p_user_name VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO app_user (
        phone_number,
        password_hash,
        user_name,
        registration_time
    )
    VALUES (
        p_phone_number,
        p_password_hash,
        p_user_name,
        NOW()
    );
END;
$$;

-- =========================================================
-- Find User By Phone
-- 透過手機號碼查詢使用者
-- =========================================================
CREATE OR REPLACE FUNCTION fn_find_user_by_phone(
    p_phone_number VARCHAR
)
RETURNS TABLE (
    user_id BIGINT,
    phone_number VARCHAR,
    password_hash VARCHAR,
    user_name VARCHAR,
    registration_time TIMESTAMPTZ,
    last_login_time TIMESTAMPTZ
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        u.user_id,
        u.phone_number,
        u.password_hash,
        u.user_name,
        u.registration_time,
        u.last_login_time
    FROM app_user u
    WHERE u.phone_number = p_phone_number;
END;
$$;

-- =========================================================
-- Update Last Login Time
-- 更新最後登入時間
-- =========================================================
CREATE OR REPLACE PROCEDURE sp_update_last_login(
    IN p_user_id BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE app_user
    SET last_login_time = NOW()
    WHERE app_user.user_id = p_user_id;
END;
$$;

-- =========================================================
-- List Books
-- 查詢書籍與庫存列表
-- =========================================================
CREATE OR REPLACE FUNCTION fn_list_books()
RETURNS TABLE (
    inventory_id BIGINT,
    isbn VARCHAR,
    name VARCHAR,
    author VARCHAR,
    introduction TEXT,
    status VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        i.inventory_id,
        b.isbn,
        b.name,
        b.author,
        b.introduction,
        i.status_code AS status
    FROM inventory i
    JOIN book b
        ON i.isbn = b.isbn
    ORDER BY i.inventory_id;
END;
$$;

-- =========================================================
-- Borrow Book
-- 借書
-- 
-- 重點：
-- 1. 使用 FOR UPDATE 鎖定該筆 inventory
-- 2. 確認書籍狀態為 AVAILABLE
-- 3. 更新 inventory 狀態為 BORROWED
-- 4. 新增 borrowing_record
-- 
-- 此 Procedure 需由 Spring Service 層搭配 @Transactional 呼叫
-- =========================================================
CREATE OR REPLACE PROCEDURE sp_borrow_book(
    IN p_user_id BIGINT,
    IN p_inventory_id BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_status VARCHAR;
BEGIN
    SELECT i.status_code
    INTO v_status
    FROM inventory i
    WHERE i.inventory_id = p_inventory_id
    FOR UPDATE;

    IF v_status IS NULL THEN
        RAISE EXCEPTION 'Book inventory not found';
    END IF;

    IF v_status <> 'AVAILABLE' THEN
        RAISE EXCEPTION 'Book is not available';
    END IF;

    UPDATE inventory
    SET status_code = 'BORROWED'
    WHERE inventory.inventory_id = p_inventory_id;

    INSERT INTO borrowing_record (
        user_id,
        inventory_id,
        borrowing_time,
        return_time
    )
    VALUES (
        p_user_id,
        p_inventory_id,
        NOW(),
        NULL
    );
END;
$$;

-- =========================================================
-- Return Book
-- 還書
--
-- 重點：
-- 1. 使用 FOR UPDATE 鎖定該筆 inventory
-- 2. 確認書籍目前為 BORROWED
-- 3. 確認該使用者有未歸還紀錄
-- 4. 更新 inventory 狀態為 AVAILABLE
-- 5. 更新 borrowing_record.return_time
--
-- 此 Procedure 需由 Spring Service 層搭配 @Transactional 呼叫
-- =========================================================
CREATE OR REPLACE PROCEDURE sp_return_book(
    IN p_user_id BIGINT,
    IN p_inventory_id BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_record_id BIGINT;
    v_status VARCHAR;
BEGIN
    SELECT i.status_code
    INTO v_status
    FROM inventory i
    WHERE i.inventory_id = p_inventory_id
    FOR UPDATE;

    IF v_status IS NULL THEN
        RAISE EXCEPTION 'Book inventory not found';
    END IF;

    IF v_status <> 'BORROWED' THEN
        RAISE EXCEPTION 'Book is not currently borrowed';
    END IF;

    SELECT br.record_id
    INTO v_record_id
    FROM borrowing_record br
    WHERE br.user_id = p_user_id
      AND br.inventory_id = p_inventory_id
      AND br.return_time IS NULL
    ORDER BY br.borrowing_time DESC
    LIMIT 1;

    IF v_record_id IS NULL THEN
        RAISE EXCEPTION 'Borrowing record not found';
    END IF;

    UPDATE inventory
    SET status_code = 'AVAILABLE'
    WHERE inventory.inventory_id = p_inventory_id;

    UPDATE borrowing_record
    SET return_time = NOW()
    WHERE borrowing_record.record_id = v_record_id;
END;
$$;