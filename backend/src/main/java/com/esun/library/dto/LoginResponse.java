package com.esun.library.dto;

public record LoginResponse(
        String token,
        String tokenType,
        String userName
) {
}