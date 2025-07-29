package com.riddhi.runntrackerbackend.controller;

import com.riddhi.runntrackerbackend.entity.User;
import com.riddhi.runntrackerbackend.exception.ApiResponse;
import com.riddhi.runntrackerbackend.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("api/user")
@SecurityRequirement(name = "bearerAuth")
@Tag(name = "User APIs",description = "Get all Users, Get User by Id,Delete User by Id")
public class UserController {

    @Autowired
    UserService userService;

    @GetMapping("/get/all")
    @Operation(summary = "Get all Users by passing authorization token ")
    public List<User> getAllUsers(){
        return userService.getAllUsers();
    }

    @GetMapping("/get/{id}")
    @Operation(summary = "Get a User by passing authorization token and userId")
    public User getUserById(@PathVariable Long id){
        return  userService.getUserById(id);
    }

    @DeleteMapping("/delete/{id}")
    @Operation(summary = "Delete a User by passing authorization token and userId")
    public ResponseEntity<ApiResponse<String>> deleteUserById(@PathVariable Long id) {
        try {
            userService.deleteUserById(id);
            return ResponseEntity.ok(
                    new ApiResponse<>("success", "User deleted successfully", null)
            );
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(
                    new ApiResponse<>("error", e.getMessage(), null)
            );
        }
    }
}
