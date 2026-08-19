package com.mypoysha.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Data
public class LoanDto {
    private UUID id;
    private String type;
    private String personName;
    private BigDecimal amount;
    private BigDecimal paidAmount;
    private String note;
    private LocalDate loanDate;
    private LocalDate dueDate;
}
