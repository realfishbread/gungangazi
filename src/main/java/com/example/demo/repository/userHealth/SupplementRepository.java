package com.example.demo.repository.userHealth;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.demo.entity.userHealth.Supplement;
import com.example.demo.entity.userHealth.SupplementId;

@Repository
public interface SupplementRepository extends JpaRepository<Supplement, SupplementId> {
    List<Supplement> findByUsername(String username);
}
