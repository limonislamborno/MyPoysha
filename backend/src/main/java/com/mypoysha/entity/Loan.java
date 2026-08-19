package com.mypoysha.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.ZonedDateTime;
import java.util.UUID;

@Entity
@Table(name = "loans")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Loan {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    private String type;

    private String personName;

    private BigDecimal amount;

    private BigDecimal paidAmount;

    private String note;

    private LocalDate loanDate;

    private LocalDate dueDate;

    private ZonedDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        if (paidAmount == null) {
            paidAmount = BigDecimal.ZERO;
        }
        if (createdAt == null) {
            createdAt = ZonedDateTime.now();
        }
    }
}

