package com.example.demo.controller.userHealth;

import java.security.Principal;
import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
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

    // 새로운 식사 기록 추가
    @PostMapping("/post")
    public void addMeal(@RequestBody MealDTO mealDTO) {
        mealService.addMeal(mealDTO);
    }

    // 특정 사용자의 모든 식사 기록 조회
    @GetMapping("/get")
    public List<MealDTO> getAllMealsByUsername(
            @RequestParam(value = "username", required = false) String username, 
            Principal principal) {
        if (username == null) {
            // 인증된 사용자 이름 사용
            username = principal.getName();
        }
        return mealService.getAllMealsByUsername(username);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteMeal(@PathVariable("id") String id) {
        try {
            mealService.deleteMeal(id); // 삭제 로직 호출
            return ResponseEntity.ok("Meal deleted successfully");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error deleting meal: " + e.getMessage());
        }
    }
}
