package com.example.to_do_app.Repository;

import com.example.to_do_app.Entity.Priority;
import com.example.to_do_app.Entity.Status;
import com.example.to_do_app.Entity.Task;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TaskRepository extends JpaRepository<Task, Long> {
    List<Task> findByStatus(Status status);
    List<Task> findByPriority(Priority priority);
}