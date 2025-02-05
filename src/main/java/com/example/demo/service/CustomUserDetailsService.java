package com.example.demo.service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.example.demo.entity.User;
import com.example.demo.repository.UserRepository;

@Service
public class CustomUserDetailsService implements UserDetailsService {

    @Autowired
    private UserRepository userRepository;

    @Override
public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
    User user = userRepository.findByUsername(username)
            .orElseThrow(() -> new UsernameNotFoundException("User not found with username: " + username));

    // 구글 로그인 사용자는 패스워드가 필요 없으므로 기본값 설정
    String password = user.getIs_google_user() ? "GOOGLE_USER_PASSWORD" : user.getPassword();

    return org.springframework.security.core.userdetails.User.builder()
            .username(user.getUsername())
            .password(password)
            .build();
}


    
}