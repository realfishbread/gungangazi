package com.example.demo.service.userHealth;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.demo.DTO.userHealth.SupplementDTO;
import com.example.demo.entity.userHealth.Supplement;
import com.example.demo.repository.userHealth.SupplementRepository;

@Service
public class SupplementService {

    @Autowired
    private SupplementRepository supplementRepository;

    public void saveSupplement(SupplementDTO dto) {
        Optional<Supplement> existingSupplement = supplementRepository.findByUsernameAndDate(dto.getUsername(), dto.getDate());
        if (existingSupplement.isPresent()) {
            // 기존 데이터를 업데이트
            Supplement supplement = existingSupplement.get();
            supplement.setSupplement_taken(dto.isSupplement_taken());
            supplement.setMenstruation_recorded(dto.isMenstruation_recorded());
            supplementRepository.save(supplement);
        } else {
            // 새로운 데이터를 추가
            Supplement supplement = new Supplement();
            supplement.setUsername(dto.getUsername());
            supplement.setDate(dto.getDate());
            supplement.setSupplement_taken(dto.isSupplement_taken());
            supplement.setMenstruation_recorded(dto.isMenstruation_recorded());
            supplementRepository.save(supplement);
        }
    }

    public List<SupplementDTO> getSupplementsByUsername(String username) {
        return supplementRepository.findByUsername(username)
            .stream()
            .map(supplement -> {
                SupplementDTO dto = new SupplementDTO();
                dto.setDate(supplement.getDate());
                dto.setSupplement_taken(supplement.isSupplement_taken());
                dto.setMenstruation_recorded(supplement.isMenstruation_recorded());
                dto.setUsername(supplement.getUsername());
                return dto;
            })
            .collect(Collectors.toList());
    }


    public SupplementDTO getSupplementByUsernameAndDate(String username, LocalDate date) {
        return supplementRepository
                .findByUsernameAndDate(username, date)
                .map(SupplementDTO::fromEntity) // Entity를 DTO로 변환
                .orElse(null);
    }
}



