package com.mypoysha.service;

import com.mypoysha.dto.DashboardDto;
import com.mypoysha.entity.Loan;
import com.mypoysha.entity.Transaction;
import com.mypoysha.repo.LoanRepository;
import com.mypoysha.repo.TransactionRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Transactional(readOnly = true)
public class DashboardService {

    private final TransactionRepository transactionRepository;
    private final LoanRepository loanRepository;
    private final TransactionService transactionService;

    public DashboardService(TransactionRepository transactionRepository, LoanRepository loanRepository, TransactionService transactionService) {
        this.transactionRepository = transactionRepository;
        this.loanRepository = loanRepository;
        this.transactionService = transactionService;
    }

    public DashboardDto getDashboard(UUID userId) {
        List<Transaction> txns = transactionRepository.findByUserId(userId);
        List<Loan> loans = loanRepository.findByUserId(userId);

        BigDecimal totalIncome = txns.stream()
                .filter(t -> "income".equals(t.getType()))
                .map(Transaction::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal totalExpense = txns.stream()
                .filter(t -> "expense".equals(t.getType()))
                .map(Transaction::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal pocketBalance = totalIncome.subtract(totalExpense);

        BigDecimal totalLentDue = loans.stream()
                .filter(l -> "lent".equals(l.getType()))
                .map(l -> l.getAmount().subtract(l.getPaidAmount() != null ? l.getPaidAmount() : BigDecimal.ZERO))
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal totalBorrowedDue = loans.stream()
                .filter(l -> "borrowed".equals(l.getType()))
                .map(l -> l.getAmount().subtract(l.getPaidAmount() != null ? l.getPaidAmount() : BigDecimal.ZERO))
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        DashboardDto dto = new DashboardDto();
        dto.setPocketBalance(pocketBalance);
        dto.setTotalIncome(totalIncome);
        dto.setTotalExpense(totalExpense);
        dto.setTotalLentDue(totalLentDue);
        dto.setTotalBorrowedDue(totalBorrowedDue);

        dto.setRecentTransactions(
                txns.stream()
                        .sorted(Comparator.comparing(Transaction::getTxnDate).reversed())
                        .limit(4)
                        .map(transactionService::mapToDto)
                        .collect(Collectors.toList())
        );

        return dto;
    }
}
