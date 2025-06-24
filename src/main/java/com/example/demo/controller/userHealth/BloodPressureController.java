package com.example.demo.controller.userHealth;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody; // 추가
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.entity.userHealth.BloodPressure;
import com.example.demo.service.UserService;
import com.example.demo.service.userHealth.BloodPressureService;

@RestController
@RequestMapping("/bloodPressure")
public class BloodPressureController {

    @Autowired
    private BloodPressureService bloodPressureService;

    @Autowired
    private UserService userService; // 추가

    // 혈압 데이터 저장 (POST)
    @PostMapping("/saveBloodPressureData")
    public ResponseEntity<BloodPressure> saveBloodPressureData(@RequestBody BloodPressure bloodPressure) {
        String username = bloodPressure.getUsername();

        if (username != null && username.contains("@")) { // 이메일이면 username 변환
            String foundUsername = userService.getUsernameByEmail(username);
            if (foundUsername == null) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
            }
            bloodPressure.setUsername(foundUsername);
        }

        BloodPressure savedData = bloodPressureService.saveBloodPressureData(bloodPressure);
        return ResponseEntity.ok(savedData);
    }

    // 사용자별 혈압 데이터 가져오기 (GET)
    @GetMapping("/getBloodPressureData")
public ResponseEntity<List<BloodPressure>> getBloodPressureDataByUsername(
        @RequestParam(value = "identifier", required = false) String identifier) {
    
    if (identifier == null) {
        return ResponseEntity.badRequest().body(null); // 요청에 identifier가 없을 경우 400 반환
    }

    String username = identifier;

    if (identifier.contains("@")) { // 이메일이면 username 변환
        String foundUsername = userService.getUsernameByEmail(identifier);
        if (foundUsername == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
        }
        username = foundUsername;
    }

    List<BloodPressure> bloodPressureList = bloodPressureService.getBloodPressureDataByUsername(username);
    return ResponseEntity.ok(bloodPressureList);
}

    @DeleteMapping("/deleteBloodPressureData")
    public ResponseEntity<String> deleteBloodPressureData(@RequestParam Long id) {
        bloodPressureService.deleteBloodPressureDataById(id);
        return ResponseEntity.ok("혈압 데이터가 삭제되었습니다.");
    }
}
