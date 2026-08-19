package com.mypoysha.repo;

import com.mypoysha.entity.Plan;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;
import java.util.List;

@Repository
public interface PlanRepository extends JpaRepository<Plan, UUID> {
    List<Plan> findByUserId(UUID userId);
}

