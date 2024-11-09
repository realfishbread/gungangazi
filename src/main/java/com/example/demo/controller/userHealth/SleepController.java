package com.example.demo.controller.userHealth;

import java.security.Principal;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.entity.userHealth.Sleep;
import com.example.demo.service.userHealth.SleepService;

@RestController
@RequestMapping("/sleep")
public class SleepController {

    @Autowired
    private SleepService sleepService;

    // 수면 데이터 저장 (POST)
    @PostMapping("/saveSleepData")
    public Sleep saveSleepData(@RequestBody Sleep sleep, Principal principal) {
        // 로그인된 사용자의 username을 sleep 객체에 설정
        sleep.setUsername(principal.getName());
        return sleepService.saveSleepData(sleep);
    }

    // 현재 로그인된 사용자의 모든 수면 데이터 가져오기 (GET)
    @GetMapping("/getSleepData")
    public List<Sleep> getSleepDataByUsername(Principal principal) {
        // 로그인된 사용자의 username을 사용하여 데이터 조회
        String username = principal.getName();
        return sleepService.getSleepDataByUsername(username);
    }
}
