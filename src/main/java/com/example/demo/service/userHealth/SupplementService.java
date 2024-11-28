package com.example.demo.service.userHealth;

import java.time.LocalDate;
import java.util.List;
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

    public void saveSupplement(SupplementDTO supplementDto) {
        Supplement supplement = new Supplement();
        supplement.setUsername(supplementDto.getUsername());
        supplement.setDate(supplementDto.getDate());
        supplement.setSupplement_taken(supplementDto.isSupplement_taken());
        supplement.setMenstruation_recorded(supplementDto.isMenstruation_recorded());
        supplementRepository.save(supplement);
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



