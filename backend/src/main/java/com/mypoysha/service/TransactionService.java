package com.mypoysha.service;

import com.mypoysha.dto.TransactionDto;
import com.mypoysha.entity.Category;
import com.mypoysha.entity.Transaction;
import com.mypoysha.repo.CategoryRepository;
import com.mypoysha.repo.TransactionRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Transactional
public class TransactionService {

    private final TransactionRepository transactionRepository;
    private final CategoryRepository categoryRepository;

    public TransactionService(TransactionRepository transactionRepository, CategoryRepository categoryRepository) {
        this.transactionRepository = transactionRepository;
        this.categoryRepository = categoryRepository;
    }

    public List<TransactionDto> getTransactions(UUID userId) {
        return transactionRepository.findByUserId(userId).stream().map(this::mapToDto).collect(Collectors.toList());
    }

    public TransactionDto createTransaction(UUID userId, TransactionDto dto) {
        Transaction txn = new Transaction();
        txn.setUserId(userId);
        txn.setType(dto.getType());
        
        Category category = categoryRepository.findById(dto.getCategoryId())
            .orElseThrow(() -> new RuntimeException("Category not found"));
        txn.setCategory(category);
        
        txn.setAmount(dto.getAmount());
        txn.setNote(dto.getNote());
        txn.setTxnDate(dto.getTxnDate());
        
        // Note: linkedLoan should be handled primarily through LoanService for consistency,
        // but can be set here if needed for direct transaction creation

        Transaction saved = transactionRepository.save(txn);
        return mapToDto(saved);
    }

    public void deleteTransaction(UUID id, UUID userId) {
        Transaction txn = transactionRepository.findById(id).orElseThrow(() -> new RuntimeException("Transaction not found"));
        if (!txn.getUserId().equals(userId)) {
            throw new RuntimeException("Unauthorized");
        }
        transactionRepository.delete(txn);
    }

    public TransactionDto mapToDto(Transaction txn) {
        TransactionDto dto = new TransactionDto();
        dto.setId(txn.getId());
        dto.setType(txn.getType());
        dto.setCategoryId(txn.getCategory() != null ? txn.getCategory().getId() : null);
        dto.setAmount(txn.getAmount());
        dto.setNote(txn.getNote());
        dto.setTxnDate(txn.getTxnDate());
        dto.setLinkedLoanId(txn.getLinkedLoan() != null ? txn.getLinkedLoan().getId() : null);
        return dto;
    }
}
