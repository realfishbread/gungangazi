package com.example.demo.controller.userHealth;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
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
    public Sleep saveSleepData(@RequestBody Sleep sleep) {
        return sleepService.saveSleepData(sleep);
    }

    // 모든 수면 데이터 가져오기 (GET)
   @GetMapping("/getSleepData")
    public List<Sleep> getSleepDataByUsername(@RequestParam String username) {
        return sleepService.getSleepDataByUsername(username);
    }
}