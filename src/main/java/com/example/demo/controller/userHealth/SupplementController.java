package com.example.demo.controller.userHealth;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
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

}

