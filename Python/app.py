import os

class TodoApp:
    def __init__(self):
        self.tasks = []
        self.file_name = "tasks.txt"
        self.load_tasks()

    def display_menu(self):
        print("=== To-Do List ===")
        print("1. Add Task")
        print("2. View Tasks")
        print("3. Remove Task")
        print("4. Exit")
        choice = input("Choose an option: ")
        return choice

    def add_task(self):
        tasks_input = input("Enter the tasks separated by '/': ")
        new_tasks = [task.strip() for task in tasks_input.split('/') if task.strip()]
        
        if new_tasks:
            self.tasks.extend(new_tasks)
            self.save_tasks()
            print("Tasks added!")

    def view_tasks(self):
        if not self.tasks:
            print("No tasks available.")
            return
        
        print("=== Your Tasks ===")
        for i, task in enumerate(self.tasks, start=1):
            print(f"{i}. {task}")

    def remove_task(self):
        self.view_tasks()
        
        if not self.tasks:
            return
        
        task_number = int(input("Enter the task number to remove (type 0 to remove all tasks): "))
        
        if 0 < task_number <= len(self.tasks):
            removed_task = self.tasks.pop(task_number - 1)
            self.save_tasks()
            print(f"Task '{removed_task}' removed!")
        elif task_number == 0:
            self.clear_all_tasks()
        else:
            print("Invalid task number.")

    def clear_all_tasks(self):
        self.tasks.clear()
        self.save_tasks()
        print("All tasks cleared!")

    def save_tasks(self):
        with open(self.file_name, 'w') as file:
            file.write('\n'.join(self.tasks))

    def load_tasks(self):
        if os.path.exists(self.file_name):
            with open(self.file_name, 'r') as file:
                self.tasks = [line.strip() for line in file if line.strip()]

    def run(self):
        while True:
            choice = self.display_menu()
            
            if choice == '1':
                self.add_task()
            elif choice == '2':
                self.view_tasks()
            elif choice == '3':
                self.remove_task()
            elif choice == '4':
                print("Exiting...")
                break
            else:
                print("Invalid choice. Please try again.")
            
            print()

if __name__ == "__main__":
    app = TodoApp()
    app.run()