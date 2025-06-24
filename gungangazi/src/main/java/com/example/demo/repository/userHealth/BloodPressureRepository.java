package com.example.demo.repository.userHealth;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.demo.entity.userHealth.BloodPressure;

@Repository
public interface BloodPressureRepository extends JpaRepository<BloodPressure, Long> {
    List<BloodPressure> findByUsername(String username);
}
