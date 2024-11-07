package com.example.demo.service.userHealth;
import com.example.demo.entity.userHealth.Sleep;
import com.example.demo.repository.userHealth.SleepRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class SleepService {

    @Autowired
    private SleepRepository sleepRepository;

    public Sleep saveSleepData(Sleep sleep) {
        return sleepRepository.save(sleep);
    }

    public List<Sleep> getSleepDataByUsername(String username) {
        return sleepRepository.findByUsername(username);
    }
}