package com.esun.library.service;

import com.esun.library.dto.BookResponse;
import com.esun.library.repository.BookRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class BookService {

    private final BookRepository bookRepository;

    public BookService(BookRepository bookRepository) {
        this.bookRepository = bookRepository;
    }

    public List<BookResponse> listBooks() {
        return bookRepository.listBooks();
    }
}