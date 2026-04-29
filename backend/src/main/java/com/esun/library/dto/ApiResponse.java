package com.esun.library.dto;

public record ApiResponse(
        boolean success,
        String message
) {
}