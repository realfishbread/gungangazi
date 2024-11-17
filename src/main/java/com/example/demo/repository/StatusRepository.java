package com.example.demo.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import com.example.demo.entity.Status;
@Repository
public interface StatusRepository extends JpaRepository<Status, Long> {
    Optional<Status> findByUsername(String username);

    @Modifying
    @Query("UPDATE Status u SET u.waterLevel = 0, u.mealLevel = 0, u.sleepLevel = 0")
    void resetDailyLevels();
}