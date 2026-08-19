package com.mypoysha.dto;

import lombok.Data;
import java.time.LocalDate;
import java.util.UUID;

@Data
public class PlanDto {
    private UUID id;
    private LocalDate planDate;
    private String text;
}
