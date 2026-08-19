package com.mypoysha.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.util.List;

@Data
public class DashboardDto {
    private BigDecimal pocketBalance;
    private BigDecimal totalIncome;
    private BigDecimal totalExpense;
    private BigDecimal totalLentDue;
    private BigDecimal totalBorrowedDue;
    private List<TransactionDto> recentTransactions;
}
