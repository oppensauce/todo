#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_TASKS 100
#define MAX_TASK_LENGTH 256
#define FILE_NAME "tasks.txt"

typedef struct {
    char tasks[MAX_TASKS][MAX_TASK_LENGTH];
    int task_count;
} TodoApp;

void loadTasks(TodoApp *app) {
    FILE *file = fopen(FILE_NAME, "r");
    if (!file) return; // File not found, no tasks to load

    while (fgets(app->tasks[app->task_count], MAX_TASK_LENGTH, file) && app->task_count < MAX_TASKS) {
        app->tasks[app->task_count][strcspn(app->tasks[app->task_count], "\n")] = 0; // Remove newline
        app->task_count++;
    }
    fclose(file);
}

void saveTasks(TodoApp *app) {
    FILE *file = fopen(FILE_NAME, "w");
    for (int i = 0; i < app->task_count; i++) {
        fprintf(file, "%s\n", app->tasks[i]);
    }
    fclose(file);
}

void displayMenu() {
    printf("=== To-Do List ===\n");
    printf("1. Add Task\n");
    printf("2. View Tasks\n");
    printf("3. Remove Task\n");
    printf("4. Exit\n");
    printf("Choose an option: ");
}

void addTask(TodoApp *app) {
    if (app->task_count >= MAX_TASKS) {
        printf("Task limit reached. Cannot add more tasks.\n");
        return;
    }

    printf("Enter the tasks separated by '/': ");
    char input[MAX_TASK_LENGTH * 10]; // Allow for multiple tasks
    fgets(input, sizeof(input), stdin);

    char *token = strtok(input, "/");
    while (token != NULL && app->task_count < MAX_TASKS) {
        token[strcspn(token, "\n")] = 0; // Remove newline
        if (strlen(token) > 0) {
            strcpy(app->tasks[app->task_count], token);
            app->task_count++;
        }
        token = strtok(NULL, "/");
    }

    saveTasks(app);
    printf("Tasks added!\n");
}

void viewTasks(TodoApp *app) {
    if (app->task_count == 0) {
        printf("No tasks available.\n");
        return;
    }

    printf("=== Your Tasks ===\n");
    for (int i = 0; i < app->task_count; i++) {
        printf("%d. %s\n", i + 1, app->tasks[i]);
    }
}

void removeTask(TodoApp *app) {
    viewTasks(app);
    
    if (app->task_count == 0) return;

    printf("Enter the task number to remove (type 0 to remove all tasks): ");
    int taskNumber;
    scanf("%d", &taskNumber);
    
    if (taskNumber > 0 && taskNumber <= app->task_count) {
        for (int i = taskNumber - 1; i < app->task_count - 1; i++) {
            strcpy(app->tasks[i], app->tasks[i + 1]);
        }
        app->task_count--;
        saveTasks(app);
        printf("Task removed!\n");
    } else if (taskNumber == 0) {
        app->task_count = 0;
        saveTasks(app);
        printf("All tasks cleared!\n");
    } else {
        printf("Invalid task number.\n");
    }
}

int main() {
    TodoApp app;
    app.task_count = 0;
    
    loadTasks(&app);

    while (1) {
        displayMenu();
        
        int choice;
        scanf("%d", &choice);
        getchar(); // Consume newline character

        switch (choice) {
            case 1:
                addTask(&app);
                break;
            case 2:
                viewTasks(&app);
                break;
            case 3:
                removeTask(&app);
                break;
            case 4:
                printf("Exiting...\n");
                return 0;
            default:
                printf("Invalid choice. Please try again.\n");
        }
        
        printf("\n");
    }

    return 0;
}