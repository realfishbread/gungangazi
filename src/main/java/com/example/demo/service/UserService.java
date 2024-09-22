package com.example.demo.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.example.demo.entity.User;
import com.example.demo.repository.UserRepository;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    @Transactional
    public void createAndDeleteUser(User newUser, Long deleteUserId) {
        userRepository.save(newUser); //새로운 유저 생성

     // 중간에 예외 발생시 전체 트랜잭션 롤백
        if (newUser.getName().equals("Error")) {
            throw new RuntimeException("강제 예외 발생");
        }

        // 유저 삭제 (에러가 발생하면 이 작업도 롤백됨)
        userRepository.deleteById(deleteUserId);
    }
}


