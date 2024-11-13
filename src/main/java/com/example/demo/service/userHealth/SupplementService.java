package com.example.demo.service.userHealth;

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
        supplement.setDate(supplementDto.getDate());
        supplement.setSupplementTaken(supplementDto.isSupplementTaken());
        supplement.setMenstruationRecorded(supplementDto.isMenstruationRecorded());
        supplement.setUsername(supplementDto.getUsername());
        supplementRepository.save(supplement);
    }

    public List<SupplementDTO> getSupplementsByUsername(String username) {
        return supplementRepository.findByUsername(username)
            .stream()
            .map(supplement -> {
                SupplementDTO dto = new SupplementDTO();
                dto.setDate(supplement.getDate());
                dto.setSupplementTaken(supplement.isSupplementTaken());
                dto.setMenstruationRecorded(supplement.isMenstruationRecorded());
                dto.setUsername(supplement.getUsername());
                return dto;
            })
            .collect(Collectors.toList());
    }
}
