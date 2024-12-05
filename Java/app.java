import java.io.*;
import java.util.ArrayList;
import java.util.Scanner;

public class app {
    private ArrayList<String> tasks;
    private Scanner scanner;
    private final String FILE_NAME = "tasks.txt";

    public app() {
        tasks = new ArrayList<>();
        scanner = new Scanner(System.in);
        loadTasks();
    }

    public void displayMenu() {
        System.out.println("=== To-Do List ===");
        System.out.println("1. Add Task");
        System.out.println("2. View Tasks");
        System.out.println("3. Remove Task");
        System.out.println("4. Exit");
        System.out.print("Choose an option: ");
    }

    public void addTask() {
        System.out.print("Enter the tasks separated by '/': ");
        String input = scanner.nextLine();
        String[] newTasks = input.split("/");

        for (String task : newTasks) {
            task = task.trim();
            if (!task.isEmpty()) {
                tasks.add(task);
            }
        }
        
        saveTasks();
        System.out.println("Tasks added!");
    }

    public void viewTasks() {
        if (tasks.isEmpty()) {
            System.out.println("No tasks available.");
            return;
        }
        
        System.out.println("=== Your Tasks ===");
        for (int i = 0; i < tasks.size(); i++) {
            System.out.println((i + 1) + ". " + tasks.get(i));
        }
    }

    public void removeTask() {
        viewTasks();
        if (tasks.isEmpty()) return;

        System.out.print("Enter the task number to remove (type 0 and press to remove all task): ");
        int taskNumber = scanner.nextInt();
        scanner.nextLine(); // Consume newline
        if (taskNumber > 0 && taskNumber <= tasks.size()) {
            tasks.remove(taskNumber - 1);
            saveTasks();
            System.out.println("Task removed!");
        }  else if (taskNumber == 0) {
            clearAllTasks();
        }
        else {
            System.out.println("Invalid task number.");
        }
    }

    public void clearAllTasks() {
        tasks.clear();
        saveTasks();
        System.out.println("All tasks cleared!");
    }

    private void saveTasks() {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(FILE_NAME))) {
            for (String task : tasks) {
                writer.write(task);
                writer.newLine();
            }
        } catch (IOException e) {
            System.err.println("Error saving tasks: " + e.getMessage());
        }
    }

    private void loadTasks() {
        try (BufferedReader reader = new BufferedReader(new FileReader(FILE_NAME))) {
            String line;
            while ((line = reader.readLine()) != null) {
                tasks.add(line);
            }
        } catch (FileNotFoundException e) {
            // File not found, no tasks to load
        } catch (IOException e) {
            System.err.println("Error loading tasks: " + e.getMessage());
        }
    }

    public void run() {
        while (true) {
            displayMenu();
            int choice = scanner.nextInt();
            scanner.nextLine(); // Consume newline
            
            switch (choice) {
                case 1:
                    addTask();
                    break;
                case 2:
                    viewTasks();
                    break;
                case 3:
                    removeTask();
                    break;
                case 4:
                    System.out.println("Exiting...");
                    return;
                default:
                    System.out.println("Invalid choice. Please try again.");
            }
            System.out.println();
        }
    }

    public static void main(String[] args) {
        app app = new app();
        app.run();
    }
}