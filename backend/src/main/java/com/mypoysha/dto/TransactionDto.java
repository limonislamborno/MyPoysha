package com.mypoysha.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Data
public class TransactionDto {
    private UUID id;
    private String type;
    private String categoryId;
    private BigDecimal amount;
    private String note;
    private LocalDate txnDate;
    private UUID linkedLoanId;
}
