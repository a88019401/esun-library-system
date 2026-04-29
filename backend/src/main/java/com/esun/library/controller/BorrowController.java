package com.esun.library.controller;

import com.esun.library.dto.ApiResponse;
import com.esun.library.service.BorrowService;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/borrows")
public class BorrowController {

    private final BorrowService borrowService;

    public BorrowController(BorrowService borrowService) {
        this.borrowService = borrowService;
    }

    @PostMapping("/{inventoryId}")
    public ApiResponse borrowBook(
            @PathVariable Long inventoryId,
            Authentication authentication
    ) {
        Long userId = (Long) authentication.getPrincipal();
        //使用者身份不是前端傳來的，而是從 JWT 解析出來的。
        borrowService.borrowBook(userId, inventoryId);

        return new ApiResponse(true, "借閱成功");
    }

    @PostMapping("/{inventoryId}/return")
    public ApiResponse returnBook(
            @PathVariable Long inventoryId,
            Authentication authentication
    ) {
        Long userId = (Long) authentication.getPrincipal();

        borrowService.returnBook(userId, inventoryId);

        return new ApiResponse(true, "還書成功");
    }
}