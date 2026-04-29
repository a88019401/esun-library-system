package com.esun.library.controller;

import com.esun.library.dto.ApiResponse;
import com.esun.library.dto.RegisterRequest;
import com.esun.library.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    public ApiResponse register(@Valid @RequestBody RegisterRequest request) {
        authService.register(request);
        return new ApiResponse(true, "註冊成功");
    }
}