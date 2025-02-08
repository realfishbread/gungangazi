package com.example.demo.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import java.util.Optional; // Optional 사용



import com.example.demo.entity.Status;
import com.example.demo.repository.StatusRepository;
import com.example.demo.repository.UserRepository;
import com.example.demo.service.StatusService;
import com.example.demo.entity.User;

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
    public ResponseEntity<String> saveStatus(@RequestBody Status status) {
        System.out.println("Received Status - Username: " + status.getUsername() + 
        ", Water Level: " + status.getWater_level() + 
        ", Meal Level: " + status.getMeal_level() + 
        ", Sleep Level: " + status.getSleep_level());
        statusService.saveStatus(status);
        return ResponseEntity.ok("Status saved successfully");
    }

    // 상태 불러오기 API
    @GetMapping
    public ResponseEntity<Status> getStatus(@RequestParam String username) {
        return statusService.getStatusByUsername(username)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    public Optional<Status> getStatusByUsername(String loginValue) {
        if (loginValue.contains("@")) { // 이메일이면 변환
            Optional<User> user = userRepository.findByEmail(loginValue);
            if (user.isPresent()) {
                String realUsername = user.get().getUsername();
                System.out.println("📢 이메일을 username으로 변환: " + loginValue + " → " + realUsername);
                return statusRepository.findByUsername(realUsername);
            }
        }
        return statusRepository.findByUsername(loginValue);
    }

}