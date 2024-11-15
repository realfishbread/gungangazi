package com.example.demo.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.entity.Status;
import com.example.demo.service.StatusService;

@RestController
@RequestMapping("/character/status")
public class StatusController {

    @Autowired
    private StatusService statusService;

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
}