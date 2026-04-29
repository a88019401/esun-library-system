package com.esun.library.entity;

public class AppUser {

    private Long userId;
    private String phoneNumber;
    private String passwordHash;
    private String userName;

    public AppUser(Long userId, String phoneNumber, String passwordHash, String userName) {
        this.userId = userId;
        this.phoneNumber = phoneNumber;
        this.passwordHash = passwordHash;
        this.userName = userName;
    }

    public Long getUserId() {
        return userId;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public String getUserName() {
        return userName;
    }
}