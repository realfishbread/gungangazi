package com.example.demo.controller.userHealth;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.DTO.userHealth.BrushHistoryDTO;
import com.example.demo.service.userHealth.BrushHistoryService;

@RestController
@RequestMapping("/brushHistory")
public class BrushHistoryController {

    @Autowired
    private BrushHistoryService brushHistoryService;

    @GetMapping("/{username}")
    public ResponseEntity<List<BrushHistoryDTO>> getBrushHistoryByUsername(@PathVariable String username) {
        List<BrushHistoryDTO> history = brushHistoryService.getBrushHistoryByUsername(username);
        return ResponseEntity.ok(history);
    }

    @PostMapping("/{username}/save")
    public ResponseEntity<Void> saveBrushHistory(@PathVariable String username, @RequestBody BrushHistoryDTO dto) {
        brushHistoryService.saveBrushHistory(username, dto);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteBrushHistory(@PathVariable Long id) {
        brushHistoryService.deleteById(id);
        return ResponseEntity.noContent().build(); // HTTP 204 반환
    }
}
