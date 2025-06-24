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
import com.example.demo.service.UserService;
import com.example.demo.service.userHealth.WaterIntakeService;

@RestController
@RequestMapping("/waterIntake")
public class WaterIntakeController {
    private final WaterIntakeService waterIntakeService;
    private final UserService userService; // 추가

    public WaterIntakeController(WaterIntakeService waterIntakeService, UserService userService) {
        this.waterIntakeService = waterIntakeService;
        this.userService = userService; // 추가
    }
    // 유저별 물 섭취 기록 가져오기
    @GetMapping("/{identifier}")
public ResponseEntity<List<WaterIntake>> getAllWaterIntakeByUsername(@PathVariable String identifier) {
    String username = identifier;

    if (identifier.contains("@")) { // 이메일이면 username 변환
        String foundUsername = userService.getUsernameByEmail(identifier);
        
        if (foundUsername == null) {
            System.out.println("❌ No username found for email: " + identifier); // 디버깅 추가
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
        }
        
        username = foundUsername;
    }

    System.out.println("✅ Fetching water intake data for username: " + username); // 디버깅 추가
    List<WaterIntake> waterIntakeList = waterIntakeService.getAllWaterIntakeByUsername(username);
    return ResponseEntity.ok(waterIntakeList);
}
    // 유저별 물 섭취 기록 저장하기
    @PostMapping("/{identifier}/save")
public ResponseEntity<Void> saveWaterIntake(
    @PathVariable String identifier,
    @RequestBody List<Map<String, Object>> waterIntakeData
) {
    String username = identifier;

    if (identifier.contains("@")) { // 이메일이면 username 변환
        String foundUsername = userService.getUsernameByEmail(identifier);
        if (foundUsername == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
        username = foundUsername;
    }

    final String fixedUsername = username; // ✅ Lambda에서 사용하기 위해 final 변수 선언

    // waterIntakeData의 각 날짜와 amount 데이터를 WaterIntake 객체로 변환
    List<WaterIntake> waterIntakeList = waterIntakeData.stream().map(data -> {
        String dateStr = (String) data.get("date");
        Integer amount = (Integer) data.get("amount");

        WaterIntake waterIntake = new WaterIntake();
        waterIntake.setUsername(fixedUsername); // ✅ 오류 없이 final 변수 사용
        waterIntake.setDate(LocalDate.parse(dateStr));
        waterIntake.setAmount(amount);
        return waterIntake;
    }).collect(Collectors.toList());

    // 리스트로 저장
    waterIntakeService.saveWaterIntakeList(waterIntakeList);
    return ResponseEntity.status(HttpStatus.CREATED).build();
}

}