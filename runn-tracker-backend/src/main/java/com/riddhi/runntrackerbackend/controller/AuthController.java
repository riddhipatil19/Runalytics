package com.riddhi.runntrackerbackend.controller;

import com.riddhi.runntrackerbackend.dto.LoginRequestDTO;
import com.riddhi.runntrackerbackend.dto.SignupRequestDTO;
import com.riddhi.runntrackerbackend.entity.User;
import com.riddhi.runntrackerbackend.exception.ApiResponse;
import com.riddhi.runntrackerbackend.service.JwtService;
import com.riddhi.runntrackerbackend.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@Tag(name = "Authentication APIs",description = "SignUp and Login")
public class AuthController {

    @Autowired
    private UserService userService;

    @Autowired
    private JwtService jwtService;

    // 🔐 Signup
    @PostMapping("/signup")
    @Operation(summary = "SignUp User to the Application" )
    public ResponseEntity<?> signUp(@RequestBody SignupRequestDTO dto) {
        try {
            User newUser = new User();
            newUser.setName(dto.getName());
            newUser.setEmail(dto.getEmail());
            newUser.setPassword(dto.getPassword());
            User savedUser = userService.signUp(newUser);
            Map<String, Object> userData = Map.of(
                    "id", savedUser.getId(),
                    "name", savedUser.getName(),
                    "email", savedUser.getEmail()
            );
            return ResponseEntity.ok(new ApiResponse<>("success", "User registered successfully", userData));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(new ApiResponse<>("error", e.getMessage(), null));
        }
    }

    // 🔐 Login
    @PostMapping("/login")
    @Operation(summary = "Login User to the Application")
    public ResponseEntity<?> login(@RequestBody LoginRequestDTO dto) {
        try {
            String email = dto.getEmail();
            String password = dto.getPassword();

            String token = userService.login(email,password, jwtService);
            User user = userService.getUserByEmail(email).get();
            Map<String, Object> userData = Map.of(
                    "id", user.getId(),
                    "name", user.getName(),
                    "email", user.getEmail(),
                    "token",token
            );
            return ResponseEntity.ok(new ApiResponse<>("success", "Login successful", userData));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(new ApiResponse<>("error", e.getMessage(), null));
        }
    }
}
