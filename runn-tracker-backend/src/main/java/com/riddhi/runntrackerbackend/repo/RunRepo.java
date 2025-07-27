package com.riddhi.runntrackerbackend.repo;

import com.riddhi.runntrackerbackend.entity.Run;
import com.riddhi.runntrackerbackend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RunRepo extends JpaRepository<Run,Long> {

    //get all runs of user
    List<Run> findByUser(User user);

    //ret runs sorted by newest
    List<Run> findByUserOrderByStartTimeDesc(User user);
}
