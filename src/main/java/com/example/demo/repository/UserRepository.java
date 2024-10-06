package com.example.demo.repository;

import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User, Long> {
    boolean existsByUsername(String username); // 사용자 아이디 중복 확인 메서드
}
