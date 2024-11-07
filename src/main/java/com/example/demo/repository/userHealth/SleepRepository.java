package com.example.demo.repository.userHealth;

import com.example.demo.entity.userHealth.Sleep;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SleepRepository extends JpaRepository<Sleep, Long> {
}