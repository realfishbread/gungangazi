package com.example.demo.service.userHealth;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.demo.repository.userHealth.MealRepository;
import com.example.demo.DTO.userHealth.MealDTO;
import com.example.demo.entity.userHealth.MealEntity;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class MealService {

    private final MealRepository mealRepository;

    @Autowired
    public MealService(MealRepository mealRepository) {
        this.mealRepository = mealRepository;
    }

    // 날짜별 식사 기록 조회
    public List<MealDTO> getMealsByDate(String date) {
        List<MealEntity> mealEntities = mealRepository.findByDate(date);
        return mealEntities.stream()
                .map(entity -> new MealDTO(entity.getDate(), entity.getMeal()))
                .collect(Collectors.toList());
    }

    // 새로운 식사 기록 추가
    public void addMeal(MealDTO mealDTO) {
        MealEntity mealEntity = new MealEntity(mealDTO.getDate(), mealDTO.getMeal());
        mealRepository.save(mealEntity);
    }
}
