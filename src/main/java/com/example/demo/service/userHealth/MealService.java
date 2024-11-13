package com.example.demo.service.userHealth;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.demo.DTO.userHealth.MealDTO;
import com.example.demo.entity.userHealth.MealEntity;
import com.example.demo.repository.userHealth.MealRepository;

@Service
public class MealService {

    private final MealRepository mealRepository;

    @Autowired
    public MealService(MealRepository mealRepository) {
        this.mealRepository = mealRepository;
    }

    // 날짜별 식사 기록 조회
    public List<MealDTO> getMealsByDate(String date, String username) {
        List<MealEntity> mealEntities = mealRepository.findByDateAndUsername(date, username);  // username도 필터링
        return mealEntities.stream()
                .map(entity -> new MealDTO(entity.getDate(), entity.getMeal(), entity.getUsername()))
                .collect(Collectors.toList());
    }

    // 새로운 식사 기록 추가
    public void addMeal(MealDTO mealDTO) {
        MealEntity mealEntity = new MealEntity(mealDTO.getDate(), mealDTO.getMeal(), mealDTO.getUsername());  // username 포함
        mealRepository.save(mealEntity);
    }
}
