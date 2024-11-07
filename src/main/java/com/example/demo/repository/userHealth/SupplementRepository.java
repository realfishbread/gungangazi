package com.example.demo.repository.userHealth;

import java.time.LocalDate;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.demo.entity.userHealth.Supplement;

@Repository
public interface SupplementRepository extends JpaRepository<Supplement, LocalDate> {
    // 추가적으로 필요한 쿼리 메소드가 있다면 여기에 정의
}