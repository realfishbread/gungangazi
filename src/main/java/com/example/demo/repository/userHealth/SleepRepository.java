package com.example.demo.repository.userHealth;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.demo.entity.userHealth.Sleep;

@Repository
public interface SleepRepository extends JpaRepository<Sleep, Long> {
    List<Sleep> findByUsername(String username);
}