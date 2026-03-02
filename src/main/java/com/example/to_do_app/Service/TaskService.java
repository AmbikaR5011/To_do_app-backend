package com.example.to_do_app.Service;

import com.example.to_do_app.Entity.Status;
import com.example.to_do_app.Entity.Task;
import com.example.to_do_app.Repository.TaskRepository;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Service
public class TaskService {

    private final TaskRepository taskRepository;

    public TaskService(TaskRepository taskRepository) {
        this.taskRepository = taskRepository;
    }

    // Create Task
    public Task createTask(Task task) {
        return taskRepository.save(task);
    }

    // Get All Tasks
    public List<Task> getAllTasks() {
        return taskRepository.findAll();
    }

    // Get Task By Id
    public Task getTaskById(Long id) {
        return taskRepository.findById(id).orElse(null);
    }

    // Delete Task
    public void deleteTask(Long id) {
        taskRepository.deleteById(id);
    }

    public Task updateTask(Long id, Task updatedTask) {
        Task task = taskRepository.findById(id).orElse(null);
        if (task != null) {
            task.setTitle(updatedTask.getTitle());
            task.setDescription(updatedTask.getDescription());
            task.setPriority(updatedTask.getPriority());
            task.setStatus(updatedTask.getStatus());
            task.setDueDate(updatedTask.getDueDate());
            return taskRepository.save(task);
        }
        return null;
    }

    public List<Task> getByStatus(Status status) {
        return taskRepository.findByStatus(status);
    }

    public Task markAsCompleted(Long id) {
        Task task = taskRepository.findById(id).orElse(null);
        if (task != null) {
            task.setStatus(Status.COMPLETED);
            return taskRepository.save(task);
        }
        return null;
    }

    public Task updateStatus(Long id, String status) {
        Task task = taskRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Task not found"));

        task.setStatus(Status.valueOf(status));
        return taskRepository.save(task);
    }
}