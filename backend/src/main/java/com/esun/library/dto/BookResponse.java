package com.esun.library.dto;

public record BookResponse(
        Long inventoryId,
        String isbn,
        String name,
        String author,
        String introduction,
        String status
) {
}