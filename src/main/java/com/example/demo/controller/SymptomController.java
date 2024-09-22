package com.example.demo.controller;

import com.example.demo.entity.Symptom;
import com.example.demo.service.SymptomService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/symptoms")
public class SymptomController {

    @Autowired
    private SymptomService symptomService;

    // 모든 증상 조회
    @GetMapping
    public List<Symptom> getAllSymptoms() {
        return symptomService.getAllSymptoms();
    }

    // 새로운 증상 추가
    @PostMapping
    public Symptom addSymptom(@RequestBody Symptom symptom) {
        return symptomService.saveSymptom(symptom);
    }
}
