package com.mypoysha.controller;

import com.mypoysha.service.ReportService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/reports")
public class ReportController {

    private final ReportService reportService;

    public ReportController(ReportService reportService) {
        this.reportService = reportService;
    }

    @GetMapping("/monthly-trend")
    public ResponseEntity<List<Map<String, Object>>> getMonthlyTrend(
            @RequestParam(defaultValue = "6") int months,
            Authentication authentication) {
        UUID userId = (UUID) authentication.getPrincipal();
        return ResponseEntity.ok(reportService.getMonthlyTrend(userId, months));
    }

    @GetMapping("/category-breakdown")
    public ResponseEntity<List<Map<String, Object>>> getCategoryBreakdown(
            @RequestParam String month,
            Authentication authentication) {
        UUID userId = (UUID) authentication.getPrincipal();
        return ResponseEntity.ok(reportService.getCategoryBreakdown(userId, month));
    }
}
