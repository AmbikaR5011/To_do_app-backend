package com.example.to_do_app.Controller;

import com.example.to_do_app.Entity.Status;
import com.example.to_do_app.Entity.Task;
import com.example.to_do_app.Service.TaskService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/tasks")
@CrossOrigin(origins = "*")   // for React later
public class TaskController {

    private final TaskService taskService;

    public TaskController(TaskService taskService) {
        this.taskService = taskService;
    }

    // Create Task
    @PostMapping
    public Task createTask(@RequestBody Task task) {
        return taskService.createTask(task);
    }

    // Get All Tasks
    @GetMapping
    public List<Task> getAllTasks() {
        return taskService.getAllTasks();
    }

    // Get Task By Id
    @GetMapping("/{id}")
    public Task getTaskById(@PathVariable Long id) {
        return taskService.getTaskById(id);
    }

    // Delete Task
    @DeleteMapping("/{id}")
    public void deleteTask(@PathVariable Long id) {
        taskService.deleteTask(id);
    }

    @PutMapping("/{id}")
    public Task updateTask(@PathVariable Long id, @RequestBody Task task) {
        return taskService.updateTask(id, task);
    }

    @GetMapping("/status/{status}")
    public List<Task> getByStatus(@PathVariable Status status) {
        return taskService.getByStatus(status);
    }

    @PutMapping("/{id}/complete")
    public Task markAsCompleted(@PathVariable Long id) {
        return taskService.markAsCompleted(id);
    }

    @PutMapping("/{id}/status")
    public Task updateStatus(@PathVariable Long id, @RequestParam String status) {
        return taskService.updateStatus(id, status);
    }
}