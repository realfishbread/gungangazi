

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

@Entity
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long memberId;
    private String memberName;
    private String memberEmail;

    // 기본 생성자 (JPA에서 필요)
    public User() {}

    // 매개변수 있는 생성자
    public User(String memberName, String memberEmail) {
        this.memberName = memberName;
        this.memberEmail = memberEmail;
    }

    // Getter and Setter for 'memberId'
    public Long getMemberId() {
        return memberId;
    }

    public void setMemberId(Long memberId) {
        this.memberId = memberId;
    }

    // Getter and Setter for 'memberName'
    public String getMemberName() {
        return memberName;
    }

    public void setMemberName(String memberName) {
        this.memberName = memberName;
    }

    // Getter and Setter for 'memberEmail'
    public String getMemberEmail() {
        return memberEmail;
    }

    public void setMemberEmail(String memberEmail) {
        this.memberEmail = memberEmail;
    }
}

