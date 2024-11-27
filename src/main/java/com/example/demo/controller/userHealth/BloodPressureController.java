package com.example.demo.controller.userHealth;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.entity.userHealth.BloodPressure;
import com.example.demo.service.userHealth.BloodPressureService;

@RestController
@RequestMapping("/bloodPressure")
public class BloodPressureController {

    @Autowired
    private BloodPressureService bloodPressureService;

    // 혈압 데이터 저장 (POST)
    @PostMapping("/saveBloodPressureData")
    public BloodPressure saveBloodPressureData(@RequestBody BloodPressure bloodPressure) {
        return bloodPressureService.saveBloodPressureData(bloodPressure);
    }

    // 사용자별 혈압 데이터 가져오기 (GET)
    @GetMapping("/getBloodPressureData")
    public List<BloodPressure> getBloodPressureDataByUsername(@RequestParam String username) {
        return bloodPressureService.getBloodPressureDataByUsername(username);
    }

    @DeleteMapping("/deleteBloodPressureData/{id}")
    public String deleteBloodPressureData(@RequestParam Long id) {
        bloodPressureService.deleteBloodPressureDataById(id);
        return "혈압 데이터가 삭제되었습니다.";
    }
}
