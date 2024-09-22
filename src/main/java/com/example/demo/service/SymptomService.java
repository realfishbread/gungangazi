package com.example.demo.service;

import com.example.demo.entity.Symptom;
import com.example.demo.repository.SymptomRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class SymptomService {

    @Autowired
    private SymptomRepository symptomRepository;

    // 모든 증상 조회
    public List<Symptom> getAllSymptoms() {
        return symptomRepository.findAll();
    }

    // 증상 저장
    public Symptom saveSymptom(Symptom symptom) {
        return symptomRepository.save(symptom);
    }
}
