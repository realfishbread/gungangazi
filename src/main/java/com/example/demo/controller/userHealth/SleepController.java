package com.example.demo.controller.userHealth;

import java.security.Principal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.DTO.userHealth.SleepDto;
import com.example.demo.entity.userHealth.Sleep;
import com.example.demo.repository.userHealth.SleepRepository;
import com.example.demo.service.userHealth.SleepService;

@RestController
@RequestMapping("/sleep")
public class SleepController {

    @Autowired
    private SleepService sleepService;
    
    @Autowired
    private SleepRepository sleepRepository;

    // 수면 데이터 저장 (POST)
    @PostMapping("/saveSleepData")
    public ResponseEntity<?> saveSleepData(@RequestBody List<SleepDto> sleepData) {
    DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("H:mm:ss"); // 유연한 시간 처리
    sleepData.forEach(data -> {
        Sleep sleep = new Sleep();
        sleep.setUsername(data.getUsername());
        sleep.setDate(LocalDate.parse(data.getDate())); // String -> LocalDate
        try {
            sleep.setSleepTime(LocalTime.parse(data.getSleepTime(), timeFormatter));
            sleep.setWakeUpTime(LocalTime.parse(data.getWakeUpTime(), timeFormatter));
        } catch (DateTimeParseException e) {
            throw new IllegalArgumentException("Invalid time format: " + e.getMessage());
        }
        sleepRepository.save(sleep);
    });
    return ResponseEntity.ok("Data saved successfully");
}

    // 현재 로그인된 사용자의 모든 수면 데이터 가져오기 (GET)
    @GetMapping("/getSleepData")
    public List<Sleep> getSleepDataByUsername(Principal principal) {
        // 로그인된 사용자의 username을 사용하여 데이터 조회
        String username = principal.getName();
        return sleepService.getSleepDataByUsername(username);
    }
}
