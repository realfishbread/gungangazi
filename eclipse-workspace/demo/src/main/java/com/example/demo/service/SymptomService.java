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
    // 증상 저장
    public Symptom saveSymptom(Symptom symptom) {
        return symptomRepository.save(symptom);
    }

    

    // 특정 조건(예: 증상 이름)에 맞는 증상 조회
    public List<Symptom> getSymptomsByName(String name) {
        return symptomRepository.findByNameContainingIgnoreCase(name);
    }

    // 특정 진단 문진을 ID로 조회
    public Optional<Symptom> getDiagnosticQuestionnaireById(Long id) {
        return symptomRepository.findById(id);
    }
}
