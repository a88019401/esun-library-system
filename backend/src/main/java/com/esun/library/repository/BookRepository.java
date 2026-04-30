package com.esun.library.repository;

import com.esun.library.dto.BookResponse;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class BookRepository {

    private final JdbcTemplate jdbcTemplate;

    public BookRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public List<BookResponse> findAll(Long userId) {
        return jdbcTemplate.query(
                "SELECT * FROM fn_list_books(?)",
                (rs, rowNum) -> new BookResponse(
                        rs.getLong("inventory_id"),
                        rs.getString("isbn"),
                        rs.getString("name"),
                        rs.getString("author"),
                        rs.getString("introduction"),
                        rs.getString("status"),
                        rs.getBoolean("borrowed_by_me")
                ),
                userId
        );
    }
}