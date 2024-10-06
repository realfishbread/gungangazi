package com.example.demo.service;


import com.example.demo.entity.User;
import com.example.demo.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private BCryptPasswordEncoder passwordEncoder;

    public void saveUser(User user) {
        String username = user.getUsername();  // getUsername 메서드 호출
        String encryptedPassword = passwordEncoder.encode(user.getPassword());  // getPassword 메서드 호출
        user.setPassword(encryptedPassword);
        userRepository.save(user);
    }
}
