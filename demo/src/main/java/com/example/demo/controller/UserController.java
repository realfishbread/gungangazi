import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.beans.factory.annotation.Autowired;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
public class UserController {

    @Autowired
    private BCryptPasswordEncoder passwordEncoder;

    @Autowired
    private UserRepository userRepository;

    @PostMapping("/signup")
    public ResponseEntity<?> signUp(@RequestBody User user) {
        // 중복 아이디 검사
        if (userRepository.existsByUsername(user.getUsername())) {
            Map<String, String> response = new HashMap<>();
            response.put("message", "아이디가 이미 존재합니다.");
            return ResponseEntity.badRequest().body(response);
        }

        // 비밀번호 암호화
        user.setPassword(passwordEncoder.encode(user.getPassword()));

        // 사용자 저장
        userRepository.save(user);
        Map<String, String> response = new HashMap<>();
        response.put("message", "회원가입 성공");
        return ResponseEntity.ok(response);
    }
}
