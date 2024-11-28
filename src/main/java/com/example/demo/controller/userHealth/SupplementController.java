package com.example.demo.controller.userHealth;

import java.time.LocalDate;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.DTO.userHealth.SupplementDTO;
import com.example.demo.service.userHealth.SupplementService;

@RestController
@RequestMapping("/supplements")
public class SupplementController {

    @Autowired
    private SupplementService supplementService;

    @PostMapping("/save")
    public void saveSupplement(@RequestBody SupplementDTO supplementDto) {
        supplementService.saveSupplement(supplementDto);
    }

    @GetMapping("/all")
    public List<SupplementDTO> getSupplementsByUsername(Authentication authentication) {
        String username = authentication.getName(); // 인증된 사용자의 username 가져오기
        return supplementService.getSupplementsByUsername(username);
    }

    @GetMapping("/single")
    public ResponseEntity<SupplementDTO> getSingleSupplement(
            @RequestParam String username,
            @RequestParam String date) {
        try {
            LocalDate parsedDate = LocalDate.parse(date); // ISO 형식의 날짜 파싱
            SupplementDTO supplement = supplementService.getSupplementByUsernameAndDate(username, parsedDate);
            if (supplement != null) {
                return ResponseEntity.ok(supplement);
            } else {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(null);
        }
    }

}

