package com.example.demo.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import com.example.demo.DTO.ProfileDto;
import com.example.demo.DTO.UserDTO;
import com.example.demo.entity.User;
import com.example.demo.repository.UserRepository;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private BCryptPasswordEncoder passwordEncoder;  // BCryptPasswordEncoder 추가

    // 회원가입 로직
    public User registerUser(UserDTO userDTO) {
        // 비밀번호 암호화
        String encryptedPassword = passwordEncoder.encode(userDTO.getPassword());
        userDTO.setPassword(encryptedPassword); // 암호화된 비밀번호 설정

        // DTO를 엔티티로 변환하고 데이터베이스에 저장
        User user = userDTO.toEntity();
        return userRepository.save(user);
    }

    public User login(String username, String password){
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("유저를 찾을 수 없습니다."));

        // 입력한 비밀번호와 암호화된 비밀번호를 비교 (BCryptPasswordEncoder의 matches 메서드 사용)
        if (!passwordEncoder.matches(password, user.getPassword())) {
            throw new RuntimeException("사용 불가한 비밀번호입니다.");
        }

        return user;
    }

    
    public ProfileDto getUserProfileByUsername(String username) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다."));
        
        // ProfileDto로 필요한 정보만 반환
        return new ProfileDto(user.getUsername(), user.getRealname(), user.getEmail(), user.getHeight(), user.getWeight(), user.getGender(), user.getProfile_image(), String.valueOf(user.getAge()));
    }
    



      // 사용자 정보 업데이트
      public User updateUser(String username, ProfileDto profileDto) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다."));
    
        // 업데이트할 필드들에 대해 개별적인 조건을 추가
        if (profileDto.getRealname() != null) {
            user.setRealname(profileDto.getRealname());
        }
        if (profileDto.getEmail() != null) {
            user.setEmail(profileDto.getEmail());
        }
        if (profileDto.getHeight() != null) {
            user.setHeight(profileDto.getHeight());
        }
        if (profileDto.getWeight() != null) {
            user.setWeight(profileDto.getWeight());
        }
        if (profileDto.getGender() != null) {
            user.setGender(profileDto.getGender());
        }
         if (profileDto.getProfile_image() != null) {
            user.setProfile_image(profileDto.getProfile_image()); // Base64 이미지 저장
        }
        if (profileDto.getAge() != null) { // 나이 업데이트
            try {
                user.setAge(Integer.parseInt(profileDto.getAge())); // String -> int 변환
            } catch (NumberFormatException e) {
                throw new RuntimeException("유효하지 않은 나이 값입니다."); // 변환 실패 시 예외 처리
            }
        }
        
    
        return userRepository.save(user);  // 업데이트된 사용자 저장
    }

    
}
