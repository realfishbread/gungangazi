package com.example.demo.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;
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
            updatedStatus.setWaterLevel(status.getWaterLevel());
            updatedStatus.setMealLevel(status.getMealLevel());
            updatedStatus.setSleepLevel(status.getSleepLevel());
            return statusRepository.save(updatedStatus);
        }
        return statusRepository.save(status);
    }

    public Optional<Status> getStatusByUsername(String username) {
        return statusRepository.findByUsername(username);
    }
}