-- =========================================================
-- 03_seed.sql
-- Seed Data for ESUN Library Borrowing System
-- Database: Supabase PostgreSQL
-- =========================================================

-- =========================================================
-- Inventory Status Seed Data
-- =========================================================
INSERT INTO inventory_status (status_code, status_name)
VALUES
('AVAILABLE', '在庫'),
('BORROWED', '出借中'),
('PROCESSING', '整理中'),
('LOST', '遺失'),
('DAMAGED', '損毀'),
('DISCARDED', '廢棄');

-- =========================================================
-- Book Seed Data
-- =========================================================
INSERT INTO book (isbn, name, author, introduction)
VALUES
('9789865020011', 'Clean Code', 'Robert C. Martin', 'A handbook of agile software craftsmanship.'),
('9789865020028', 'Effective Java', 'Joshua Bloch', 'Best practices for Java programming.'),
('9789865020035', 'Spring Boot in Action', 'Craig Walls', 'A practical guide to Spring Boot development.'),
('9789865020042', 'Design Patterns', 'Erich Gamma', 'Reusable object-oriented software design patterns.'),
('9789865020059', 'Refactoring', 'Martin Fowler', 'Improving the design of existing code.');

-- =========================================================
-- Inventory Seed Data
-- 同一本書可以有多本實體庫存
-- =========================================================
INSERT INTO inventory (isbn, status_code)
VALUES
('9789865020011', 'AVAILABLE'),
('9789865020011', 'AVAILABLE'),
('9789865020028', 'AVAILABLE'),
('9789865020035', 'AVAILABLE'),
('9789865020042', 'AVAILABLE'),
('9789865020059', 'AVAILABLE');