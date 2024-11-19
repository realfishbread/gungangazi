package com.example.demo.controller.userHealth;

import java.security.Principal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
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
    DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("H:mm:ss");

    for (SleepDto data : sleepData) {
        // 중복 체크
        boolean exists = sleepRepository.existsByUsernameAndDate(data.getUsername(), LocalDate.parse(data.getDate()));
        if (exists) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                                 .body("수면 데이터가 이미 저장되어 있습니다: " + data.getDate());
        }

        // 데이터 저장
        Sleep sleep = new Sleep();
        sleep.setUsername(data.getUsername());
        sleep.setDate(LocalDate.parse(data.getDate()));
        try {
            sleep.setSleep_time(LocalTime.parse(data.getSleep_time(), timeFormatter));
            sleep.setWake_up_time(LocalTime.parse(data.getWake_up_time(), timeFormatter));
        } catch (DateTimeParseException e) {
            throw new IllegalArgumentException("잘못된 시간 형식: " + e.getMessage());
        }
        sleepRepository.save(sleep);
    }

    return ResponseEntity.ok("데이터가 성공적으로 저장되었습니다.");
}

    // 현재 로그인된 사용자의 모든 수면 데이터 가져오기 (GET)
    @GetMapping("/getSleepData")
    public List<Sleep> getSleepDataByUsername(Principal principal) {
        // 로그인된 사용자의 username을 사용하여 데이터 조회
        String username = principal.getName();
        return sleepService.getSleepDataByUsername(username);
    }
}
