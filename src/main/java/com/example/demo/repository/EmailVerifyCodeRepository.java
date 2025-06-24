package com.example.demo.repository;

import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;
import com.example.demo.entity.EmailVerifyCode;

@Repository
public interface EmailVerifyCodeRepository extends CrudRepository<EmailVerifyCode, String> {
}