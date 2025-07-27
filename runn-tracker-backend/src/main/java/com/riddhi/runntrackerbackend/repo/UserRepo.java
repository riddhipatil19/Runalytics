package com.riddhi.runntrackerbackend.repo;

import com.riddhi.runntrackerbackend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepo extends JpaRepository<User,Long> {

    //find user by email
    Optional<User> findByEmail(String email);
}

