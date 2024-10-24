import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Map;

@RestController
public class AIController {

    @PostMapping("/callAI")
    public Map<String, Object> callAI(@RequestBody Map<String, List<String>> requestData) {
        String flaskUrl = "http://localhost:5000/predict";  // Flask 서버 URL

        // RestTemplate을 사용해 Flask 서버에 요청 보냄
        RestTemplate restTemplate = new RestTemplate();

        // 요청 헤더 설정
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        // Flask에 보낼 요청 데이터
        HttpEntity<Map<String, List<String>>> entity = new HttpEntity<>(requestData, headers);

        // Flask 서버에 POST 요청
        ResponseEntity<Map> response = restTemplate.exchange(flaskUrl, HttpMethod.POST, entity, Map.class);

        // Flask에서 받은 응답을 클라이언트로 반환
        return response.getBody();
    }
}
