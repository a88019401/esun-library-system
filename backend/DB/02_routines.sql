CREATE OR REPLACE FUNCTION fn_list_books(p_user_id BIGINT DEFAULT NULL)
RETURNS TABLE (
    inventory_id BIGINT,
    isbn VARCHAR,
    name VARCHAR,
    author VARCHAR,
    introduction TEXT,
    status VARCHAR,
    borrowed_by_me BOOLEAN
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
        i.status_code AS status,
        EXISTS (
            SELECT 1
            FROM borrowing_record br
            WHERE br.inventory_id = i.inventory_id
              AND br.user_id = p_user_id
              AND br.return_time IS NULL
        ) AS borrowed_by_me
    FROM inventory i
    JOIN book b
      ON i.isbn = b.isbn
    ORDER BY i.inventory_id;
END;
$$;