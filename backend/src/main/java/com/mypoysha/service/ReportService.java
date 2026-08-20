package com.mypoysha.service;

import com.mypoysha.entity.Transaction;
import com.mypoysha.repo.TransactionRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.*;
import java.util.stream.Collectors;

@Service
@Transactional(readOnly = true)
public class ReportService {

    private final TransactionRepository transactionRepository;

    public ReportService(TransactionRepository transactionRepository) {
        this.transactionRepository = transactionRepository;
    }

    public List<Map<String, Object>> getMonthlyTrend(UUID userId, int months) {
        List<Transaction> txns = transactionRepository.findByUserId(userId);
        
        Map<YearMonth, Map<String, BigDecimal>> trendMap = new TreeMap<>();
        YearMonth currentMonth = YearMonth.now();
        
        for (int i = 0; i < months; i++) {
            YearMonth ym = currentMonth.minusMonths(i);
            Map<String, BigDecimal> data = new HashMap<>();
            data.put("income", BigDecimal.ZERO);
            data.put("expense", BigDecimal.ZERO);
            trendMap.put(ym, data);
        }

        for (Transaction t : txns) {
            YearMonth ym = YearMonth.from(t.getTxnDate());
            if (trendMap.containsKey(ym)) {
                Map<String, BigDecimal> data = trendMap.get(ym);
                if ("income".equals(t.getType())) {
                    data.put("income", data.get("income").add(t.getAmount()));
                } else if ("expense".equals(t.getType())) {
                    data.put("expense", data.get("expense").add(t.getAmount()));
                }
            }
        }

        List<Map<String, Object>> result = new ArrayList<>();
        for (Map.Entry<YearMonth, Map<String, BigDecimal>> entry : trendMap.entrySet()) {
            Map<String, Object> item = new HashMap<>();
            item.put("id", entry.getKey().toString()); // "2026-08"
            item.put("income", entry.getValue().get("income"));
            item.put("expense", entry.getValue().get("expense"));
            result.add(item);
        }

        return result;
    }

    public List<Map<String, Object>> getCategoryBreakdown(UUID userId, String monthStr) {
        YearMonth targetMonth = YearMonth.parse(monthStr);
        List<Transaction> txns = transactionRepository.findByUserId(userId).stream()
                .filter(t -> YearMonth.from(t.getTxnDate()).equals(targetMonth))
                .filter(t -> "expense".equals(t.getType()))
                .collect(Collectors.toList());

        Map<String, BigDecimal> categoryMap = new HashMap<>();
        for (Transaction t : txns) {
            String catId = (t.getCategory() != null && t.getCategory().getId() != null) ? t.getCategory().getId() : "other";
            BigDecimal amt = t.getAmount() != null ? t.getAmount() : BigDecimal.ZERO;
            categoryMap.put(catId, categoryMap.getOrDefault(catId, BigDecimal.ZERO).add(amt));
        }

        List<Map<String, Object>> result = new ArrayList<>();
        for (Map.Entry<String, BigDecimal> entry : categoryMap.entrySet()) {
            Map<String, Object> item = new HashMap<>();
            item.put("id", entry.getKey());
            item.put("value", entry.getValue());
            result.add(item);
        }

        // Sort by value descending
        result.sort((a, b) -> ((BigDecimal) b.get("value")).compareTo((BigDecimal) a.get("value")));
        return result;
    }
}
