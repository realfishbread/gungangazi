package com.example.demo.service.userHealth;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.demo.entity.userHealth.BloodPressure;
import com.example.demo.repository.userHealth.BloodPressureRepository;

@Service
public class BloodPressureService {

    @Autowired
    private BloodPressureRepository bloodPressureRepository;

    public BloodPressure saveBloodPressureData(BloodPressure bloodPressure) {
        return bloodPressureRepository.save(bloodPressure);
    }

    public List<BloodPressure> getBloodPressureDataByUsername(String username) {
        return bloodPressureRepository.findByUsername(username);
    }
}
