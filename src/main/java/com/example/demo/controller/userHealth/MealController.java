package com.example.demo.controller.userHealth;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.DTO.userHealth.MealDTO;
import com.example.demo.service.userHealth.MealService;


@RestController
@RequestMapping("/meals")
public class MealController {

    private final MealService mealService;

    public MealController(MealService mealService) {
        this.mealService = mealService;
    }

    // 날짜별 식사 기록 조회
    @GetMapping("/get")
    public List<MealDTO> getMealsByDate(@RequestParam String date, @RequestParam String username) {
        // Flutter에서 보내준 username과 date를 이용해 데이터를 조회
        return mealService.getMealsByDate(date, username);  
    }

    // 새로운 식사 기록 추가
    @PostMapping("/post")
    public void addMeal(@RequestBody MealDTO mealDTO) {
        mealService.addMeal(mealDTO);
    }
}