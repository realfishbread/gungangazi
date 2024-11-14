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
                config.addAllowedOrigin("https://gungangazi.site");
                config.addAllowedOrigin("http://localhost:8080");
                config.addAllowedHeader("*");
                config.addAllowedMethod("*");
                return config;
            }))
            .csrf(csrf -> csrf.disable())
            .authorizeHttpRequests(authz -> authz
                .requestMatchers(new AntPathRequestMatcher("/login", "POST")).permitAll()
                .requestMatchers(new AntPathRequestMatcher("/signup", "POST")).permitAll()
                .requestMatchers(new AntPathRequestMatcher("/profile", "GET")).authenticated()
                .requestMatchers(new AntPathRequestMatcher("/{username}/update", "PUT")).authenticated()
                .requestMatchers(new AntPathRequestMatcher("/waterIntake", "GET")).authenticated()
                .requestMatchers(new AntPathRequestMatcher("/waterIntake/{username}", "PUT")).authenticated()
                .requestMatchers(new AntPathRequestMatcher("/brushHistory/{username}", "GET")).authenticated()
                .requestMatchers(new AntPathRequestMatcher("/brushHistory/{username}/save", "PUT")).authenticated()
                .requestMatchers(new AntPathRequestMatcher("/sleep/getSleepData", "GET")).authenticated()
                .requestMatchers(new AntPathRequestMatcher("/sleep/saveSleepData", "POST")).authenticated()
                .requestMatchers(new AntPathRequestMatcher("/meals/post", "POST")).permitAll()
                .requestMatchers(new AntPathRequestMatcher("/meals/put", "PUT")).permitAll()
                .requestMatchers(new AntPathRequestMatcher("/supplements/save", "POST")).permitAll()
                .requestMatchers(new AntPathRequestMatcher("/supplements/all", "GET")).permitAll()
                .requestMatchers(new AntPathRequestMatcher("/character/status", "POST")).permitAll()
                .requestMatchers(new AntPathRequestMatcher("/character/status", "GET")).permitAll()
                .anyRequest().authenticated()
            )
            .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class); // JWT 필터 추가
        return http.build();
    }
}

