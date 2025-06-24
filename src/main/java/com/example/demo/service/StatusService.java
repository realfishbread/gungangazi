package com.example.demo.service;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.demo.entity.Status;
import com.example.demo.repository.StatusRepository;
import com.example.demo.DTO.StatusDto;
import com.example.demo.entity.User;
import com.example.demo.repository.UserRepository;;

@Service
public class StatusService {

    @Autowired
    private StatusRepository statusRepository;

    @Autowired
    private UserRepository userRepository;

    public Optional<Status> getStatusByUsername(String loginValue) {
        if (loginValue.contains("@")) { // 입력이 이메일인지 확인
            Optional<User> user = userRepository.findByEmail(loginValue);
            if (user.isPresent()) {
                loginValue = user.get().getUsername(); // 이메일 → username 변환
                System.out.println("📢 이메일을 username으로 변환: " + loginValue);
            } else {
                System.out.println("❌ 이메일에 해당하는 사용자가 없습니다: " + loginValue);
                return Optional.empty();
            }
        }

        Optional<Status> status = statusRepository.findByUsername(loginValue);
        if (status.isPresent()) {
            System.out.println("✅ 사용자 상태 정보 조회 성공: " + loginValue);
        } else {
            System.out.println("⚠️ 해당 username에 대한 상태 정보가 없습니다: " + loginValue);
        }

        return status;
    }

    public void saveStatus(StatusDto statusDto) {
        String loginValue = statusDto.getUsername(); // username 또는 email

        // 1️⃣ 이메일이면 username으로 변환
        if (loginValue.contains("@")) { 
            Optional<User> user = userRepository.findByEmail(loginValue);
            if (user.isPresent()) {
                loginValue = user.get().getUsername(); // 이메일을 username으로 변환
                System.out.println("📢 이메일을 username으로 변환: " + loginValue);
            } else {
                System.out.println("❌ 해당 이메일의 사용자를 찾을 수 없습니다: " + loginValue);
                throw new RuntimeException("해당 이메일의 사용자를 찾을 수 없습니다.");
            }
        }

        // 2️⃣ 기존 상태 정보 확인 (중복 저장 방지)
        Optional<Status> existingStatus = statusRepository.findByUsername(loginValue);
        if (existingStatus.isPresent()) {
            // 기존 데이터가 있으면 업데이트
            Status status = existingStatus.get();
            status.setWater_level(statusDto.getWater_level());
            status.setMeal_level(statusDto.getMeal_level());
            status.setSleep_level(statusDto.getSleep_level());
            statusRepository.save(status);
            System.out.println("🔄 기존 상태 정보 업데이트 완료: " + loginValue);
        } else {
            // 기존 데이터가 없으면 새로 저장
            Status newStatus = new Status(loginValue, statusDto.getWater_level(), statusDto.getMeal_level(), statusDto.getSleep_level());
            statusRepository.save(newStatus);
            System.out.println("✅ 새 상태 정보 저장 완료: " + loginValue);
        }
    }
}
