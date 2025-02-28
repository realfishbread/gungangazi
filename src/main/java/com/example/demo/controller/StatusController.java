package com.example.demo.controller;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
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
        Status status = statusDto.toEntity(); // DTO → Entity 변환
        statusRepository.save(status); // 저장
        return ResponseEntity.ok("Status saved successfully");
    }

    // 상태 불러오기 API
    @GetMapping
    public ResponseEntity<StatusDto> getStatus(@RequestParam String username) {
    Optional<Status> statusOptional = getStatusByUsername(username);

    if (statusOptional.isEmpty()) {
        return ResponseEntity.notFound().build(); // 상태 정보를 찾을 수 없으면 404 반환
    }

    // 🔥 엔티티 → DTO 변환
    Status status = statusOptional.get();
    StatusDto statusDto = new StatusDto();
    statusDto.setUsername(status.getUsername());
    statusDto.setWater_level(status.getWater_level());
    statusDto.setMeal_level(status.getMeal_level());
    statusDto.setSleep_level(status.getSleep_level());

    return ResponseEntity.ok(statusDto);
}

// 🔥 중복 제거된 이메일 변환 + 상태 조회 메서드
    public Optional<Status> getStatusByUsername(String loginValue) {
        if (loginValue.contains("@")) { // 이메일이면 username으로 변환
            Optional<User> user = userRepository.findByEmail(loginValue);
            if (user.isPresent()) {
                loginValue = user.get().getUsername(); // 이메일 → username 변환
                System.out.println("📢 이메일을 username으로 변환: " + loginValue);
            } else {
                System.out.println("❌ 이메일에 해당하는 사용자가 없습니다: " + loginValue);
                return Optional.empty(); // 이메일에 해당하는 사용자가 없음
            }
        }
        return statusRepository.findByUsername(loginValue);
    }

}