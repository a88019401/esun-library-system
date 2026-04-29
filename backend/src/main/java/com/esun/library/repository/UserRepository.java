//這裡一樣遵守 Stored Routine：
//SELECT * FROM fn_find_user_by_phone(?)
//CALL sp_register_user(?, ?, ?)
//沒有直接拼接 SQL，所以也比較能避免 SQL Injection。

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
}