package com.mypoysha.controller;

import com.mypoysha.dto.PlanDto;
import com.mypoysha.service.PlanService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/plans")
public class PlanController {

    private final PlanService planService;

    public PlanController(PlanService planService) {
        this.planService = planService;
    }

    @GetMapping
    public ResponseEntity<List<PlanDto>> getPlans(Authentication authentication) {
        UUID userId = (UUID) authentication.getPrincipal();
        return ResponseEntity.ok(planService.getPlans(userId));
    }

    @PostMapping
    public ResponseEntity<PlanDto> createPlan(@RequestBody PlanDto dto, Authentication authentication) {
        UUID userId = (UUID) authentication.getPrincipal();
        return ResponseEntity.ok(planService.createPlan(userId, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePlan(@PathVariable UUID id, Authentication authentication) {
        UUID userId = (UUID) authentication.getPrincipal();
        planService.deletePlan(id, userId);
        return ResponseEntity.ok().build();
    }
}
