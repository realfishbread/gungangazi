package com.example.demo.service.userHealth;

import java.util.List;

import org.springframework.stereotype.Service;

import com.example.demo.entity.userHealth.WaterIntake;
import com.example.demo.repository.userHealth.WaterIntakeRepository;

@Service
public class WaterIntakeService {
    private final WaterIntakeRepository waterIntakeRepository;

    public WaterIntakeService(WaterIntakeRepository waterIntakeRepository) {
        this.waterIntakeRepository = waterIntakeRepository;
    }

    public List<WaterIntake> getAllWaterIntakeByUsername(String username) {
        return waterIntakeRepository.findByUsername(username);
    }

    public void saveWaterIntakeList(List<WaterIntake> waterIntakeList) {
        waterIntakeRepository.saveAll(waterIntakeList);
    }
}