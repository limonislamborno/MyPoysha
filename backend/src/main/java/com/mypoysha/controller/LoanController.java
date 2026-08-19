package com.mypoysha.controller;

import com.mypoysha.dto.LoanDto;
import com.mypoysha.service.LoanService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/loans")
public class LoanController {

    private final LoanService loanService;

    public LoanController(LoanService loanService) {
        this.loanService = loanService;
    }

    @GetMapping
    public ResponseEntity<List<LoanDto>> getLoans(Authentication authentication) {
        UUID userId = (UUID) authentication.getPrincipal();
        return ResponseEntity.ok(loanService.getLoans(userId));
    }

    @PostMapping
    public ResponseEntity<LoanDto> createLoan(@RequestBody LoanDto dto, Authentication authentication) {
        UUID userId = (UUID) authentication.getPrincipal();
        return ResponseEntity.ok(loanService.createLoan(userId, dto));
    }

    @PostMapping("/{id}/payments")
    public ResponseEntity<Void> recordPayment(@PathVariable UUID id, @RequestBody Map<String, Object> payload, Authentication authentication) {
        UUID userId = (UUID) authentication.getPrincipal();
        BigDecimal amount = new BigDecimal(payload.get("amount").toString());
        LocalDate date = LocalDate.parse(payload.get("paymentDate").toString());
        loanService.recordPayment(id, userId, amount, date);
        return ResponseEntity.ok().build();
    }
}
