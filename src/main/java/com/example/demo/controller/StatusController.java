package com.example.demo.controller;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController; // Optional 사용

import com.example.demo.DTO.StatusDto;
import com.example.demo.entity.Status;
import com.example.demo.entity.User;
import com.example.demo.repository.StatusRepository;
import com.example.demo.repository.UserRepository;
import com.example.demo.service.StatusService;

@RestController
@RequestMapping("/character/status")
public class StatusController {

    @Autowired
    private StatusService statusService;

    @Autowired
    private StatusRepository statusRepository;

    @Autowired
    private UserRepository userRepository;

    // 상태 저장 API
    @PostMapping
    public ResponseEntity<String> saveStatus(@RequestBody StatusDto statusDto) {
        statusService.saveStatus(statusDto); // StatusService를 사용하도록 변경
        return ResponseEntity.ok("Status saved successfully");
    }

    // 상태 불러오기 API
   @GetMapping
    public ResponseEntity<Status> getStatus(@RequestParam String username) {
        return statusService.getStatusByUsername(username)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

// 🔥 중복 제거된 이메일 변환 + 상태 조회 메서드
    public Optional<Status> getStatusByUsername(String loginValue) {
        if (loginValue.contains("@")) { // 입력이 이메일인지 확인
            Optional<User> user = userRepository.findByEmail(loginValue);
            if (user.isPresent()) {
                loginValue = user.get().getUsername(); // 이메일 → username 변환
                System.out.println("📢 이메일을 username으로 변환: " + loginValue);
            } else {
                System.out.println("❌ 이메일에 해당하는 사용자가 없습니다: " + loginValue);
                return Optional.empty(); // 이메일에 해당하는 사용자가 없음
            }
        }

        Optional<Status> status = statusRepository.findByUsername(loginValue);
        if (status.isPresent()) {
            System.out.println("✅ 사용자 상태 정보 조회 성공: " + loginValue);
        } else {
            System.out.println("⚠️ 해당 username에 대한 상태 정보가 없습니다: " + loginValue);
        }

        return status;
    }


}