package com.example.demo.service.userHealth;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.demo.DTO.userHealth.BrushHistoryDTO;
import com.example.demo.entity.userHealth.BrushHistory;
import com.example.demo.exception.ResourceNotFoundException;
import com.example.demo.repository.userHealth.BrushHistoryRepository;



@Service
public class BrushHistoryService {

    @Autowired
    private BrushHistoryRepository brushHistoryRepository;

    public List<BrushHistoryDTO> getBrushHistoryByUsername(String username) {
        List<BrushHistory> brushHistories = brushHistoryRepository.findByUsername(username);
        return brushHistories.stream().map(this::convertToDTO).collect(Collectors.toList());
    }

    public void saveBrushHistory(String username, BrushHistoryDTO dto) {
        BrushHistory brushHistory = new BrushHistory();
        brushHistory.setUsername(username);
        brushHistory.setDate(dto.getDate());
        brushHistory.setDuration(dto.getDuration());
        brushHistory.setFlossed(dto.isFlossed());
        brushHistoryRepository.save(brushHistory);
    }

    private BrushHistoryDTO convertToDTO(BrushHistory brushHistory) {
        BrushHistoryDTO dto = new BrushHistoryDTO();
        dto.setUsername(brushHistory.getUsername());
        dto.setDate(brushHistory.getDate());
        dto.setDuration(brushHistory.getDuration());
        dto.setFlossed(brushHistory.isFlossed());
        return dto;
    }
     
    @Transactional
    public void deleteById(long id) {
        if (!brushHistoryRepository.existsById(id)) {
            throw new ResourceNotFoundException("No record found for id: " + id);
        }
        brushHistoryRepository.deleteById(id);
    }
}