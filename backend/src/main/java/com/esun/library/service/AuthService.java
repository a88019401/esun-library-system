package com.esun.library.service;

import com.esun.library.dto.LoginRequest;
import com.esun.library.dto.LoginResponse;
import com.esun.library.dto.RegisterRequest;
import com.esun.library.repository.UserRepository;
import com.esun.library.security.JwtUtil;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
//1. 用手機號碼查使用者
//2. 用 BCrypt 比對密碼
//3. 密碼正確就產生 JWT Token
@Service
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    public AuthService(
            UserRepository userRepository,
            PasswordEncoder passwordEncoder,
            JwtUtil jwtUtil
    ) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
    }

    public void register(RegisterRequest request) {
        userRepository.findByPhone(request.getPhoneNumber())
                .ifPresent(user -> {
                    throw new IllegalArgumentException("此手機號碼已註冊");
                });

        String passwordHash = passwordEncoder.encode(request.getPassword());

        userRepository.register(
                request.getPhoneNumber(),
                passwordHash,
                request.getUserName()
        );
    }

    public LoginResponse login(LoginRequest request) {
        var user = userRepository.findByPhone(request.getPhoneNumber())
                .orElseThrow(() -> new IllegalArgumentException("帳號或密碼錯誤"));

        boolean passwordMatched = passwordEncoder.matches(
                request.getPassword(),
                user.getPasswordHash()
        );

        if (!passwordMatched) {
            throw new IllegalArgumentException("帳號或密碼錯誤");
        }

        userRepository.updateLastLogin(user.getUserId());

        String token = jwtUtil.generateToken(
                user.getUserId(),
                user.getPhoneNumber(),
                user.getUserName()
        );

        return new LoginResponse(
                token,
                "Bearer",
                user.getUserName()
        );
    }
}