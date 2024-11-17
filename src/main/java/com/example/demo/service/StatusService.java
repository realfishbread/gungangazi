package com.example.demo.service;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import com.example.demo.entity.Status;
import com.example.demo.repository.StatusRepository;


@Service
public class StatusService {

    @Autowired
    private StatusRepository statusRepository;

    public Status saveStatus(Status status) {
        Optional<Status> existingStatus = statusRepository.findByUsername(status.getUsername());
        if (existingStatus.isPresent()) {
            Status updatedStatus = existingStatus.get();
            updatedStatus.setWater_level(status.getWater_level());
            updatedStatus.setMeal_level(status.getMeal_level());
            updatedStatus.setSleep_level(status.getSleep_level());
            return statusRepository.save(updatedStatus);
        }
        return statusRepository.save(status);
    }

    public Optional<Status> getStatusByUsername(String username) {
        return statusRepository.findByUsername(username);
    }

    // 매일 자정(00:00)에 실행
    @Scheduled(cron = "0 0 0 * * ?")
    public void resetDailyLevels() {
        try {
            // 모든 캐릭터의 상태 초기화
            statusRepository.resetDailyLevels();
            System.out.println("Character statuses have been reset to 0.");
        } catch (Exception e) {
            System.err.println("Error resetting character statuses: " + e.getMessage());
        }
    }
}