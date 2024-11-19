package com.example.demo.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import com.example.demo.entity.Status;
@Repository
public interface StatusRepository extends JpaRepository<Status, Long> {
    Optional<Status> findByUsername(String username);

    @Modifying
    @Transactional
    @Query("UPDATE Status u SET u.water_level = 0, u.meal_level = 0, u.sleep_level = 0")
    void resetDailyLevels();
}