package com.riddhi.runntrackerbackend.controller;

import com.riddhi.runntrackerbackend.entity.Run;
import com.riddhi.runntrackerbackend.entity.User;
import com.riddhi.runntrackerbackend.exception.ApiResponse;
import com.riddhi.runntrackerbackend.service.JwtService;
import com.riddhi.runntrackerbackend.service.RunService;
import com.riddhi.runntrackerbackend.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("api/run")
@Tag(name = "Run APIs",description = "Create Run,Get your Runs,Delete your Run")
public class RunController {

    @Autowired
    private RunService runService;

    @Autowired
    private UserService userService;

    @Autowired
    private JwtService jwtService;

    // 🆕 Add new run
    @PostMapping("/create")
    @Operation(summary = "Create your run by passing authorization token,start,end,pace,distance,duration")
    public ResponseEntity<ApiResponse<Run>> createRun(@RequestHeader("Authorization") String token,
                                                      @RequestBody Run run) {
        try {
            String email = jwtService.extractEmail(token.replace("Bearer ", ""));
            User user = userService.getUserByEmail(email).orElseThrow(() -> new RuntimeException("User not found"));
            run.setUser(user); // 🔗 Link run to authenticated user

            Run savedRun = runService.saveRun(run);
            return ResponseEntity.ok(new ApiResponse<>("success", "Run saved", savedRun));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(new ApiResponse<>("error", e.getMessage(), null));
        }
    }

    // 📋 Get runs of authenticated user
    @GetMapping("/my")
    @Operation(summary = "Get List of your Runs by passing authorization token")
    public ResponseEntity<List<Run>> getMyRuns(@RequestHeader("Authorization") String token) {
        String email = jwtService.extractEmail(token.replace("Bearer ", ""));
        User user = userService.getUserByEmail(email).orElseThrow(() -> new RuntimeException("User not found"));
        return ResponseEntity.ok(runService.getRunsByUser(user));
    }

    // 🗑 Delete a run
    @DeleteMapping("/delete/{id}")
    @Operation(summary = "Delete your Run by passing authorization token and runId")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<ApiResponse<String>> deleteRun(@PathVariable Long id) {
        try {
            runService.deleteRunById(id);
            return ResponseEntity.ok(new ApiResponse<>("success", "Run deleted", null));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(new ApiResponse<>("error", e.getMessage(), null));
        }
    }
}

