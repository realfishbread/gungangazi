package com.example.demo.repository;

import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface EmailVerificationRepository extends CrudRepository<String, String> {
    // 기본적인 Redis CRUD 사용 가능
}