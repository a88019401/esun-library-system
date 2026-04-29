package com.esun.library.repository;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class BorrowRepository {

    private final JdbcTemplate jdbcTemplate;

    public BorrowRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public void borrowBook(Long userId, Long inventoryId) {
        jdbcTemplate.update(
                "CALL sp_borrow_book(?, ?)",
                userId,
                inventoryId
        );
    }

    public void returnBook(Long userId, Long inventoryId) {
        jdbcTemplate.update(
                "CALL sp_return_book(?, ?)",
                userId,
                inventoryId
        );
    }
}