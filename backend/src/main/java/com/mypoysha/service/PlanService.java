package com.mypoysha.service;

import com.mypoysha.dto.PlanDto;
import com.mypoysha.entity.Plan;
import com.mypoysha.repo.PlanRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Transactional
public class PlanService {

    private final PlanRepository planRepository;

    public PlanService(PlanRepository planRepository) {
        this.planRepository = planRepository;
    }

    public List<PlanDto> getPlans(UUID userId) {
        return planRepository.findByUserId(userId).stream()
                .map(this::mapToDto)
                .sorted((a, b) -> {
                    if (a.getPlanDate() == null && b.getPlanDate() == null) return 0;
                    if (a.getPlanDate() == null) return 1;
                    if (b.getPlanDate() == null) return -1;
                    return a.getPlanDate().compareTo(b.getPlanDate());
                })
                .collect(Collectors.toList());
    }

    public PlanDto createPlan(UUID userId, PlanDto dto) {
        Plan plan = new Plan();
        plan.setUserId(userId);
        plan.setPlanDate(dto.getPlanDate());
        plan.setText(dto.getText());
        Plan saved = planRepository.save(plan);
        return mapToDto(saved);
    }

    public void deletePlan(UUID id, UUID userId) {
        Plan plan = planRepository.findById(id).orElseThrow(() -> new RuntimeException("Plan not found"));
        if (!plan.getUserId().equals(userId)) {
            throw new RuntimeException("Unauthorized");
        }
        planRepository.delete(plan);
    }

    private PlanDto mapToDto(Plan plan) {
        PlanDto dto = new PlanDto();
        dto.setId(plan.getId());
        dto.setPlanDate(plan.getPlanDate());
        dto.setText(plan.getText());
        return dto;
    }
}
