package com.example.demo.entity.userHealth;

import java.io.Serializable;
import java.time.LocalDate;
import java.util.Objects;

public class SupplementId implements Serializable {
    private String username;
    private LocalDate date;

    public SupplementId() {}

    public SupplementId(String username, LocalDate date) {
        this.username = username;
        this.date = date;
    }

    // equals and hashCode methods
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        SupplementId that = (SupplementId) o;
        return Objects.equals(username, that.username) &&
               Objects.equals(date, that.date);
    }

    @Override
    public int hashCode() {
        return Objects.hash(username, date);
    }

    // Getters and Setters (if needed)
}
