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
        statusService.saveStatus(statusDto);
        return ResponseEntity.ok("Status saved successfully");
    }

    @GetMapping
    public ResponseEntity<Status> getStatus(@RequestParam String username) {
        return statusService.getStatusByUsername(username)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }


}