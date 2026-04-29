//@Transactional，如果更新庫存成功，但新增借閱紀錄失敗，整個交易會 rollback。

package com.esun.library.service;

import com.esun.library.repository.BorrowRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class BorrowService {

    private final BorrowRepository borrowRepository;

    public BorrowService(BorrowRepository borrowRepository) {
        this.borrowRepository = borrowRepository;
    }

    @Transactional
    public void borrowBook(Long userId, Long inventoryId) {
        borrowRepository.borrowBook(userId, inventoryId);
    }

    @Transactional
    public void returnBook(Long userId, Long inventoryId) {
        borrowRepository.returnBook(userId, inventoryId);
    }
}