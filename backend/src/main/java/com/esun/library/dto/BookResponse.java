package com.esun.library.dto;

public class BookResponse {

    private Long inventoryId;
    private String isbn;
    private String name;
    private String author;
    private String introduction;
    private String status;
    private Boolean borrowedByMe;

    public BookResponse(
            Long inventoryId,
            String isbn,
            String name,
            String author,
            String introduction,
            String status,
            Boolean borrowedByMe
    ) {
        this.inventoryId = inventoryId;
        this.isbn = isbn;
        this.name = name;
        this.author = author;
        this.introduction = introduction;
        this.status = status;
        this.borrowedByMe = borrowedByMe;
    }

    public Long getInventoryId() {
        return inventoryId;
    }

    public String getIsbn() {
        return isbn;
    }

    public String getName() {
        return name;
    }

    public String getAuthor() {
        return author;
    }

    public String getIntroduction() {
        return introduction;
    }

    public String getStatus() {
        return status;
    }

    public Boolean getBorrowedByMe() {
        return borrowedByMe;
    }
}