package com.riddhi.runntrackerbackend.service;


import com.riddhi.runntrackerbackend.entity.User;
import com.riddhi.runntrackerbackend.repo.UserRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class UserService {
    @Autowired
    private UserRepo userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    // 🔐 Signup
    public User signUp(User user) {
        if (userRepository.findByEmail(user.getEmail()).isPresent()) {
            throw new RuntimeException("Email already in use");
        }
        String temp=user.getPassword();
        user.setPassword(passwordEncoder.encode(temp));
        return userRepository.save(user);
    }

    // 🔐 Login (basic email check; normally includes password verification)
    public String login(String email, String rawPassword,JwtService jwtService) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Invalid credentials"));

        if (!passwordEncoder.matches(rawPassword, user.getPassword())) {
            throw new RuntimeException("Invalid credentials");
        }
        return jwtService.generateToken(user);
    }

    // 📋 Get All Users
    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    // 🔍 Get User by ID
    public User getUserById(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found with ID: " + id));
    }

    // 🧹 Delete User by ID
    public void deleteUserById(Long id) {
        if (!userRepository.existsById(id)) {
            throw new RuntimeException("User with ID " + id + " does not exist");
        }
        userRepository.deleteById(id);
    }

    // 🔍 Get User by Email
    public Optional<User> getUserByEmail(String email) {
        return userRepository.findByEmail(email);
    }
}
