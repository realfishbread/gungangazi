package com.example.demo.DTO; // 적절한 패키지 경로로 변경하세요.

public class ProfileDto {
    private String username;
    private String realname;
    private String email;
    private String height;
    private String weight;
    private String gender;
    private String profileImage;

    public ProfileDto(String username, String realname, String email, String height, String weight, String gender) {
        this.username = username;
        this.realname = realname;
        this.email = email;
        this.height = height;
        this.weight = weight;
        this.gender = gender;
        
        
    }
    public String getProfileImage() {
        return profileImage;
    }

    public void setProfileImage(String profileImage) {
        this.profileImage = profileImage;
    }

    // Getter와 Setter
    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getRealname() {
        return realname;
    }

    public void setRealname(String realname) {
        this.realname = realname;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getHeight() {
        return height;
    }

    public void setHeight(String height) {
        this.height = height;
    }

    public String getWeight() {
        return weight;
    }

    public void setWeight(String weight) {
        this.weight = weight;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }
}
