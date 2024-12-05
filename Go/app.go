package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

type TodoApp struct {
	tasks     []string
	fileName  string
	scanner   *bufio.Scanner
}

func NewTodoApp() *TodoApp {
	app := &TodoApp{
		fileName: "tasks.txt",
		scanner:  bufio.NewScanner(os.Stdin),
	}
	app.loadTasks()
	return app
}

func (app *TodoApp) displayMenu() {
	fmt.Println("=== To-Do List ===")
	fmt.Println("1. Add Task")
	fmt.Println("2. View Tasks")
	fmt.Println("3. Remove Task")
	fmt.Println("4. Exit")
	fmt.Print("Choose an option: ")
}

func (app *TodoApp) addTask() {
	fmt.Print("Enter the tasks separated by '/': ")
	app.scanner.Scan()
	input := app.scanner.Text()
	newTasks := strings.Split(input, "/")

	for _, task := range newTasks {
		task = strings.TrimSpace(task)
		if task != "" {
			app.tasks = append(app.tasks, task)
		}
	}

	app.saveTasks()
	fmt.Println("Tasks added!")
}

func (app *TodoApp) viewTasks() {
	if len(app.tasks) == 0 {
		fmt.Println("No tasks available.")
		return
	}

	fmt.Println("=== Your Tasks ===")
	for i, task := range app.tasks {
		fmt.Printf("%d. %s\n", i+1, task)
	}
}

func (app *TodoApp) removeTask() {
	app.viewTasks()
	if len(app.tasks) == 0 {
		return
	}

	fmt.Print("Enter the task number to remove (type 0 to remove all tasks): ")
	var taskNumber int
	fmt.Scan(&taskNumber)

	if taskNumber > 0 && taskNumber <= len(app.tasks) {
		app.tasks = append(app.tasks[:taskNumber-1], app.tasks[taskNumber:]...)
		app.saveTasks()
		fmt.Println("Task removed!")
	} else if taskNumber == 0 {
		app.clearAllTasks()
	} else {
		fmt.Println("Invalid task number.")
	}
}

func (app *TodoApp) clearAllTasks() {
	app.tasks = []string{}
	app.saveTasks()
	fmt.Println("All tasks cleared!")
}

func (app *TodoApp) saveTasks() {
	file, err := os.Create(app.fileName)
	if err != nil {
		fmt.Printf("Error saving tasks: %v\n", err)
		return
	}
	defer file.Close()

	for _, task := range app.tasks {
		file.WriteString(task + "\n")
	}
}

func (app *TodoApp) loadTasks() {
	file, err := os.Open(app.fileName)
	if err != nil {
		if os.IsNotExist(err) {
			return // No tasks to load
		}
		fmt.Printf("Error loading tasks: %v\n", err)
		return
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		task := scanner.Text()
		if task != "" {
			app.tasks = append(app.tasks, task)
		}
	}
}

func (app *TodoApp) run() {
	for {
		app.displayMenu()
		
        var choice int
        fmt.Scan(&choice)

        switch choice {
        case 1:
            app.addTask()
        case 2:
            app.viewTasks()
        case 3:
            app.removeTask()
        case 4:
            fmt.Println("Exiting...")
            return
        default:
            fmt.Println("Invalid choice. Please try again.")
        }
        fmt.Println()
    }
}

func main() {
	app := NewTodoApp()
	app.run()
}