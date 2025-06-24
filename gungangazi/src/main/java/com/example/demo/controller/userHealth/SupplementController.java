package com.example.demo.controller.userHealth;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
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
import com.example.demo.entity.userHealth.Supplement;
import com.example.demo.repository.userHealth.SupplementRepository;
import com.example.demo.service.userHealth.SupplementService;

@RestController
@RequestMapping("/supplements")
public class SupplementController {

    @Autowired
    private SupplementRepository supplementRepository; 

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
        public ResponseEntity<Supplement> getSingleSupplement(
                @RequestParam String username,
                @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
            System.out.println("Received username: " + username + ", date: " + date);
            Optional<Supplement> supplement = supplementRepository.findByUsernameAndDate(username, date);
            if (supplement.isPresent()) {
                return ResponseEntity.ok(supplement.get());
            } else {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
            }
        }

}

