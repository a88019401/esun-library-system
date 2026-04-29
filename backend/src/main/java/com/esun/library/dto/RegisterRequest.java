package com.esun.library.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
//基本驗證
public class RegisterRequest {

    @NotBlank(message = "手機號碼不可為空")
    @Pattern(regexp = "^09\\d{8}$", message = "手機號碼格式錯誤")
    private String phoneNumber;

    @NotBlank(message = "密碼不可為空")
    @Size(min = 8, message = "密碼至少需要 8 碼")
    private String password;

    @NotBlank(message = "使用者名稱不可為空")
    private String userName;

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public String getPassword() {
        return password;
    }

    public String getUserName() {
        return userName;
    }
}