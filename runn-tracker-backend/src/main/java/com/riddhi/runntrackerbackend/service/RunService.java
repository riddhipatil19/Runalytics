package com.riddhi.runntrackerbackend.service;

import com.riddhi.runntrackerbackend.entity.Run;
import com.riddhi.runntrackerbackend.entity.User;
import com.riddhi.runntrackerbackend.repo.RunRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class RunService {
    @Autowired
    private RunRepo runRepository;

    // ✅ Save a new run
    public Run saveRun(Run run) {
        return runRepository.save(run);
    }

    // 📋 Get all runs for a specific user
    public List<Run> getRunsByUser(User user) {
        return runRepository.findByUserOrderByStartTimeDesc(user);
    }

    // 🧹 Delete a run by ID
    public void deleteRunById(Long id) {
        runRepository.deleteById(id);
    }
}

