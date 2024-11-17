package com.example.demo.repository.userHealth;

import java.time.LocalDate;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.demo.entity.userHealth.Sleep;

@Repository
public interface SleepRepository extends JpaRepository<Sleep, Long> {
    List<Sleep> findByUsername(String username);

    // 중복 확인 메서드 추가
    boolean existsByUsernameAndDate(String username, LocalDate date);
}
