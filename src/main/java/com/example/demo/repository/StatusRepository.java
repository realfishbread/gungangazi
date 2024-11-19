package com.example.demo.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.demo.entity.Status;
@Repository
public interface StatusRepository extends JpaRepository<Status, Long> {
    Optional<Status> findByUsername(String username);

}