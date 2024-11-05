package com.example.demo.controller.userHealth;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.entity.userHealth.WaterIntake;
import com.example.demo.service.userHealth.WaterIntakeService;

@RestController
@RequestMapping("/waterIntake")
public class WaterIntakeController {
    private final WaterIntakeService waterIntakeService;

    public WaterIntakeController(WaterIntakeService waterIntakeService) {
        this.waterIntakeService = waterIntakeService;
    }

    // 유저별 물 섭취 기록 가져오기
    @GetMapping
    public ResponseEntity<List<WaterIntake>> getAllWaterIntakeByUsername(@PathVariable String username) {
        List<WaterIntake> waterIntakeList = waterIntakeService.getAllWaterIntakeByUsername(username);
        return ResponseEntity.ok(waterIntakeList);
    }

    // 유저별 물 섭취 기록 저장하기
    @PostMapping("/{username}")
    public ResponseEntity<Void> saveWaterIntake(
        @PathVariable String username,
        @RequestBody List<Map<String, Object>> waterIntakeData
    ) {
        // waterIntakeData의 각 날짜와 amount 데이터를 WaterIntake 객체로 변환
        List<WaterIntake> waterIntakeList = waterIntakeData.stream().map(data -> {
            String dateStr = (String) data.get("date");
            Integer amount = (Integer) data.get("amount");

            WaterIntake waterIntake = new WaterIntake();
            waterIntake.setUsername(username);
            waterIntake.setDate(LocalDate.parse(dateStr));
            waterIntake.setAmount(amount);
            return waterIntake;
        }).collect(Collectors.toList());

        // 리스트로 저장
        waterIntakeService.saveWaterIntakeList(waterIntakeList);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }
}