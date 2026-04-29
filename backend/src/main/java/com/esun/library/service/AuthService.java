package com.esun.library.service;

import com.esun.library.dto.RegisterRequest;
import com.esun.library.repository.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
//資料庫只會存雜湊後的密碼
@Service
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public AuthService(
            UserRepository userRepository,
            PasswordEncoder passwordEncoder
    ) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
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
}