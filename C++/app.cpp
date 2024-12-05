#include <iostream>
#include <fstream>
#include <vector>
#include <sstream>
#include <string>

class TodoApp {
private:
    std::vector<std::string> tasks;
    const std::string FILE_NAME = "tasks.txt";

public:
    TodoApp() {
        loadTasks();
    }

    void displayMenu() {
        std::cout << "=== To-Do List ===\n";
        std::cout << "1. Add Task\n";
        std::cout << "2. View Tasks\n";
        std::cout << "3. Remove Task\n";
        std::cout << "4. Exit\n";
        std::cout << "Choose an option: ";
    }

    void addTask() {
        std::cout << "Enter the tasks separated by '/': ";
        std::string input;
        std::getline(std::cin, input);
        
        std::stringstream ss(input);
        std::string task;
        
        while (std::getline(ss, task, '/')) {
            task.erase(0, task.find_first_not_of(" \n\r\t")); // Trim leading whitespace
            if (!task.empty()) {
                tasks.push_back(task);
            }
        }

        saveTasks();
        std::cout << "Tasks added!\n";
    }

    void viewTasks() {
        if (tasks.empty()) {
            std::cout << "No tasks available.\n";
            return;
        }

        std::cout << "=== Your Tasks ===\n";
        for (size_t i = 0; i < tasks.size(); ++i) {
            std::cout << (i + 1) << ". " << tasks[i] << '\n';
        }
    }

    void removeTask() {
        viewTasks();
        
        if (tasks.empty()) return;

        std::cout << "Enter the task number to remove (type 0 to remove all tasks): ";
        int taskNumber;
        std::cin >> taskNumber;
        std::cin.ignore(); // Consume newline character

        if (taskNumber > 0 && taskNumber <= static_cast<int>(tasks.size())) {
            tasks.erase(tasks.begin() + (taskNumber - 1));
            saveTasks();
            std::cout << "Task removed!\n";
        } else if (taskNumber == 0) {
            clearAllTasks();
        } else {
            std::cout << "Invalid task number.\n";
        }
    }

    void clearAllTasks() {
        tasks.clear();
        saveTasks();
        std::cout << "All tasks cleared!\n";
    }

private:
    void saveTasks() {
        std::ofstream file(FILE_NAME);
        
        for (const auto& task : tasks) {
            file << task << '\n';
        }
    }

    void loadTasks() {
        std::ifstream file(FILE_NAME);
        
        if (!file) return; // File not found, no tasks to load

        std::string line;
        
        while (std::getline(file, line)) {
            if (!line.empty()) {
                tasks.push_back(line);
            }
        }
    }

public:
    void run() {
        while (true) {
            displayMenu();
            int choice;
            std::cin >> choice;
            std::cin.ignore(); // Consume newline character
            
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
                    std::cout << "Exiting...\n";
                    return;
                default:
                    std::cout << "Invalid choice. Please try again.\n";
            }
            std::cout << '\n';
        }
    }
};

int main() {
    TodoApp app;
    app.run();
    return 0;
}