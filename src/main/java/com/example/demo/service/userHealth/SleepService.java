package com.example.demo.service.userHealth;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.demo.entity.userHealth.Sleep;
import com.example.demo.repository.userHealth.SleepRepository;

@Service
public class SleepService {

    private final SleepRepository sleepRepository;

    @Autowired
    public SleepService(SleepRepository sleepRepository) {
        this.sleepRepository = sleepRepository;
    }

    public Sleep saveSleepData(Sleep sleep) {
        return sleepRepository.save(sleep);
    }

    public List<Sleep> getSleepDataByUsername(String username) {
        return sleepRepository.findByUsername(username);
    }
}
