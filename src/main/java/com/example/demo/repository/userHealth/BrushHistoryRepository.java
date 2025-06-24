package com.example.demo.repository.userHealth;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.demo.entity.userHealth.BrushHistory;

@Repository
public interface BrushHistoryRepository extends JpaRepository<BrushHistory, Long> {
    List<BrushHistory> findByUsername(String username);
}