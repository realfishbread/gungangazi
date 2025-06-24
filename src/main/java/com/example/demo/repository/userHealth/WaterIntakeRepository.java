package com.example.demo.repository.userHealth;

import java.time.LocalDate;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.demo.entity.userHealth.WaterIntake;

@Repository
public interface WaterIntakeRepository extends JpaRepository<WaterIntake, Long> {
    List<WaterIntake> findByUsernameAndDate(String username, LocalDate date);
    List<WaterIntake> findByUsername(String username);
}