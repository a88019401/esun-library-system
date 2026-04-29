package com.esun.library.repository;

import com.esun.library.entity.AppUser;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public class UserRepository {

    private final JdbcTemplate jdbcTemplate;

    public UserRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public Optional<AppUser> findByPhone(String phoneNumber) {
        var users = jdbcTemplate.query(
                "SELECT * FROM fn_find_user_by_phone(?)",
                (rs, rowNum) -> new AppUser(
                        rs.getLong("user_id"),
                        rs.getString("phone_number"),
                        rs.getString("password_hash"),
                        rs.getString("user_name")
                ),
                phoneNumber
        );

        return users.stream().findFirst();
    }

    public void register(String phoneNumber, String passwordHash, String userName) {
        jdbcTemplate.update(
                "CALL sp_register_user(?, ?, ?)",
                phoneNumber,
                passwordHash,
                userName
        );
    }

    public void updateLastLogin(Long userId) {
        jdbcTemplate.update(
                "CALL sp_update_last_login(?)",
                userId
        );
    }
}