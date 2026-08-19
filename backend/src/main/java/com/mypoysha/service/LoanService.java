package com.mypoysha.service;

import com.mypoysha.dto.LoanDto;
import com.mypoysha.entity.Category;
import com.mypoysha.entity.Loan;
import com.mypoysha.entity.LoanPayment;
import com.mypoysha.entity.Transaction;
import com.mypoysha.repo.CategoryRepository;
import com.mypoysha.repo.LoanPaymentRepository;
import com.mypoysha.repo.LoanRepository;
import com.mypoysha.repo.TransactionRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Transactional
public class LoanService {

    private final LoanRepository loanRepository;
    private final TransactionRepository transactionRepository;
    private final LoanPaymentRepository loanPaymentRepository;
    private final CategoryRepository categoryRepository;

    public LoanService(LoanRepository loanRepository, TransactionRepository transactionRepository,
                       LoanPaymentRepository loanPaymentRepository, CategoryRepository categoryRepository) {
        this.loanRepository = loanRepository;
        this.transactionRepository = transactionRepository;
        this.loanPaymentRepository = loanPaymentRepository;
        this.categoryRepository = categoryRepository;
    }

    public List<LoanDto> getLoans(UUID userId) {
        return loanRepository.findByUserId(userId).stream().map(this::mapToDto).collect(Collectors.toList());
    }

    @Transactional
    public LoanDto createLoan(UUID userId, LoanDto dto) {
        Loan loan = new Loan();
        loan.setUserId(userId);
        loan.setType(dto.getType());
        loan.setPersonName(dto.getPersonName());
        loan.setAmount(dto.getAmount());
        loan.setPaidAmount(BigDecimal.ZERO);
        loan.setNote(dto.getNote());
        loan.setLoanDate(dto.getLoanDate());
        loan.setDueDate(dto.getDueDate());
        
        Loan savedLoan = loanRepository.save(loan);

        // Atomic Transaction Rule: Create linked transaction automatically
        Transaction txn = new Transaction();
        txn.setUserId(userId);
        txn.setAmount(dto.getAmount());
        txn.setTxnDate(dto.getLoanDate());
        txn.setNote(dto.getPersonName() + " (" + dto.getNote() + ")");
        txn.setLinkedLoan(savedLoan);

        if ("lent".equals(dto.getType())) {
            txn.setType("expense");
            txn.setCategory(categoryRepository.findById("loan_given").orElseThrow());
        } else if ("borrowed".equals(dto.getType())) {
            txn.setType("income");
            txn.setCategory(categoryRepository.findById("loan_taken").orElseThrow());
        }

        transactionRepository.save(txn);

        return mapToDto(savedLoan);
    }

    @Transactional
    public void recordPayment(UUID loanId, UUID userId, BigDecimal amount, LocalDate paymentDate) {
        Loan loan = loanRepository.findById(loanId).orElseThrow(() -> new RuntimeException("Loan not found"));
        if (!loan.getUserId().equals(userId)) {
            throw new RuntimeException("Unauthorized");
        }

        BigDecimal remainingDue = loan.getAmount().subtract(loan.getPaidAmount());
        if (amount.compareTo(remainingDue) > 0) {
            amount = remainingDue; // Cap at max due amount
        }

        if (amount.compareTo(BigDecimal.ZERO) <= 0) return;

        loan.setPaidAmount(loan.getPaidAmount().add(amount));
        loanRepository.save(loan);

        // Atomic Transaction Rule: Create linked payment transaction
        Transaction txn = new Transaction();
        txn.setUserId(userId);
        txn.setAmount(amount);
        txn.setTxnDate(paymentDate);
        txn.setNote("Repayment: " + loan.getPersonName());
        txn.setLinkedLoan(loan);

        if ("lent".equals(loan.getType())) {
            txn.setType("income");
            txn.setCategory(categoryRepository.findById("loan_repay_income").orElseThrow());
        } else if ("borrowed".equals(loan.getType())) {
            txn.setType("expense");
            txn.setCategory(categoryRepository.findById("loan_repay_expense").orElseThrow());
        }

        Transaction savedTxn = transactionRepository.save(txn);

        LoanPayment payment = new LoanPayment();
        payment.setLoan(loan);
        payment.setTransaction(savedTxn);
        payment.setAmount(amount);
        payment.setPaymentDate(paymentDate);
        loanPaymentRepository.save(payment);
    }

    private LoanDto mapToDto(Loan loan) {
        LoanDto dto = new LoanDto();
        dto.setId(loan.getId());
        dto.setType(loan.getType());
        dto.setPersonName(loan.getPersonName());
        dto.setAmount(loan.getAmount());
        dto.setPaidAmount(loan.getPaidAmount());
        dto.setNote(loan.getNote());
        dto.setLoanDate(loan.getLoanDate());
        dto.setDueDate(loan.getDueDate());
        return dto;
    }
}
