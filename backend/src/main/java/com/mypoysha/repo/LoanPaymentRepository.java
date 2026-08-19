package com.mypoysha.repo;

import com.mypoysha.entity.LoanPayment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;
import java.util.List;

@Repository
public interface LoanPaymentRepository extends JpaRepository<LoanPayment, UUID> {
    List<LoanPayment> findByLoanId(UUID loanId);
}

