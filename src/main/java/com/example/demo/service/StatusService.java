package com.example.demo.service;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.demo.entity.Status;
import com.example.demo.repository.StatusRepository;
import com.example.demo.DTO.StatusDto;

@Service
public class StatusService {

    @Autowired
    private StatusRepository statusRepository;

    public Status saveStatus(StatusDto statusDto) {
        // 기존 username이 있는지 확인
        Optional<Status> existingStatus = statusRepository.findByUsername(statusDto.getUsername());

        if (existingStatus.isPresent()) {
            // 기존 데이터가 있으면 업데이트
            Status updatedStatus = existingStatus.get();
            updatedStatus.setWater_level(statusDto.getWater_level());
            updatedStatus.setMeal_level(statusDto.getMeal_level());
            updatedStatus.setSleep_level(statusDto.getSleep_level());
            return statusRepository.save(updatedStatus);
        }

        // 새로운 데이터면 생성 후 저장
        Status newStatus = new Status();
        newStatus.setUsername(statusDto.getUsername());
        newStatus.setWater_level(statusDto.getWater_level());
        newStatus.setMeal_level(statusDto.getMeal_level());
        newStatus.setSleep_level(statusDto.getSleep_level());

        return statusRepository.save(newStatus);
    }

    public Optional<Status> getStatusByUsername(String username) {
        return statusRepository.findByUsername(username);
    }
}
