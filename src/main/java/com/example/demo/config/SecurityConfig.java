package com.example.demo.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;
import org.springframework.web.cors.CorsConfiguration;

import com.example.demo.service.CustomUserDetailsService;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Autowired
    private CustomUserDetailsService customUserDetailsService;

    @Autowired
    private JwtAuthenticationFilter jwtAuthenticationFilter;

    @Bean
    public BCryptPasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration authenticationConfiguration) throws Exception {
        return authenticationConfiguration.getAuthenticationManager();
    }

    

    @Bean
public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
    http
        .cors(cors -> cors.configurationSource(request -> {
            CorsConfiguration config = new CorsConfiguration();
            config.setAllowCredentials(true);
            config.addAllowedOrigin("https://gunganghazi.site");
            config.addAllowedOrigin("https://www.gunganghazi.site");
            config.addAllowedOrigin("http://localhost:3000");
            config.addAllowedOrigin("http://localhost:8080");
            config.addExposedHeader("Authorization");
            config.addAllowedHeader("*");
            config.addAllowedMethod("*");
            return config;
        }))
        .csrf(csrf -> csrf.disable())
        .authorizeHttpRequests(authz -> authz
            .requestMatchers(new AntPathRequestMatcher("/login", "POST")).permitAll()
            .requestMatchers(new AntPathRequestMatcher("/signup", "POST")).permitAll()
            .requestMatchers(new AntPathRequestMatcher("/verify-code", "POST")).permitAll()
            .requestMatchers(new AntPathRequestMatcher("/request-email-verification", "POST")).permitAll()
            .requestMatchers(new AntPathRequestMatcher("/profile", "GET")).authenticated()
            .requestMatchers(new AntPathRequestMatcher("/{username}/update", "PUT")).authenticated()
            .requestMatchers(new AntPathRequestMatcher("/waterIntake", "GET")).authenticated()
            .requestMatchers(new AntPathRequestMatcher("/waterIntake/{identifier}", "PUT")).authenticated()
            .requestMatchers(new AntPathRequestMatcher("/waterIntake/{identifier}/save", "POST")).authenticated()
            .requestMatchers(new AntPathRequestMatcher("/brushHistory/{idendifier}", "GET")).authenticated()
            .requestMatchers(new AntPathRequestMatcher("/brushHistory/{username}/save", "PUT")).authenticated()
            .requestMatchers(new AntPathRequestMatcher("/sleep/getSleepData", "GET")).authenticated()
            .requestMatchers(new AntPathRequestMatcher("/sleep/saveSleepData", "POST")).authenticated()
            .requestMatchers(new AntPathRequestMatcher("/meals/post", "POST")).authenticated()
            .requestMatchers(new AntPathRequestMatcher("/meals/put", "PUT")).authenticated()
            .requestMatchers(new AntPathRequestMatcher("/supplements/save", "POST")).authenticated()
            .requestMatchers(new AntPathRequestMatcher("/supplements/all", "GET")).authenticated()
            .requestMatchers(new AntPathRequestMatcher("/character/status", "POST")).authenticated()
            .requestMatchers(new AntPathRequestMatcher("/character/status", "GET")).authenticated()
            .requestMatchers(new AntPathRequestMatcher("/brushHistory/{id}", "DELETE")).authenticated()
            .requestMatchers(new AntPathRequestMatcher("/bloodPressure/deleteBloodPressureData", "DELETE")).authenticated()
            .requestMatchers(new AntPathRequestMatcher("/bloodPressure/saveBloodPressureData", "POST")).authenticated()
            .requestMatchers(new AntPathRequestMatcher("/bloodPressure/getBloodPressureData", "GET")).authenticated()
            .requestMatchers(new AntPathRequestMatcher("/supplements/single", "GET")).authenticated()
            .requestMatchers(new AntPathRequestMatcher("/api/auth/google-login", "POST")).permitAll()
            .requestMatchers(new AntPathRequestMatcher("/api/auth/link-google", "POST")).permitAll()
            .requestMatchers(new AntPathRequestMatcher("/getUsernameByEmail", "GET")).permitAll()
            .anyRequest().authenticated()
        )
        .headers(headers -> headers
            .contentSecurityPolicy(csp -> csp.policyDirectives(
                "script-src 'self' 'unsafe-inline' 'unsafe-eval' https://accounts.google.com https://www.gstatic.com https://apis.google.com"
            ))
        )
        .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class); // JWT 필터 추가
    return http.build();
}

}

