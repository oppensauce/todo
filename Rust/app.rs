use std::fs::{self, OpenOptions};
use std::io::{self, BufRead, Write};
use std::path::Path;
use std::vec::Vec;

struct TodoApp {
    tasks: Vec<String>,
    file_name: &'static str,
}

impl TodoApp {
    fn new() -> Self {
        let file_name = "tasks.txt";
        let tasks = Self::load_tasks(file_name);
        TodoApp { tasks, file_name }
    }

    fn display_menu(&self) {
        println!("=== To-Do List ===");
        println!("1. Add Task");
        println!("2. View Tasks");
        println!("3. Remove Task");
        println!("4. Exit");
        print!("Choose an option: ");
    }

    fn add_task(&mut self) {
        print!("Enter the tasks separated by '/': ");
        io::stdout().flush().unwrap();
        
        let mut input = String::new();
        io::stdin().read_line(&mut input).unwrap();
        
        let new_tasks: Vec<&str> = input.split('/').map(|s| s.trim()).filter(|s| !s.is_empty()).collect();
        
        self.tasks.extend(new_tasks.iter().map(|&s| s.to_string()));
        
        self.save_tasks();
        println!("Tasks added!");
    }

    fn view_tasks(&self) {
        if self.tasks.is_empty() {
            println!("No tasks available.");
            return;
        }
        
        println!("=== Your Tasks ===");
        for (i, task) in self.tasks.iter().enumerate() {
            println!("{}. {}", i + 1, task);
        }
    }

    fn remove_task(&mut self) {
        self.view_tasks();
        
        if self.tasks.is_empty() {
            return;
        }

        print!("Enter the task number to remove (type 0 to remove all tasks): ");
        io::stdout().flush().unwrap();
        
        let mut input = String::new();
        io::stdin().read_line(&mut input).unwrap();
        
        let task_number: usize = input.trim().parse().unwrap_or(0);
        
        if task_number > 0 && task_number <= self.tasks.len() {
            self.tasks.remove(task_number - 1);
            self.save_tasks();
            println!("Task removed!");
        } else if task_number == 0 {
            self.clear_all_tasks();
        } else {
            println!("Invalid task number.");
        }
    }

    fn clear_all_tasks(&mut self) {
        self.tasks.clear();
        self.save_tasks();
        println!("All tasks cleared!");
    }

    fn save_tasks(&self) {
        let mut file = OpenOptions::new()
            .write(true)
            .truncate(true)
            .create(true)
            .open(self.file_name)
            .expect("Unable to open file");

        for task in &self.tasks {
            writeln!(file, "{}", task).expect("Unable to write data");
        }
    }

    fn load_tasks(file_name: &str) -> Vec<String> {
        let path = Path::new(file_name);
        
        if !path.exists() {
            return Vec::new(); // No tasks to load
        }

        let file = fs::File::open(file_name).expect("Unable to open file");
        
        io::BufReader::new(file)
            .lines()
            .filter_map(Result::ok)
            .collect()
    }

    fn run(&mut self) {
        loop {
            self.display_menu();

            let mut choice = String::new();
            io::stdin().read_line(&mut choice).unwrap();
            
            match choice.trim().parse::<u32>() {
                Ok(1) => self.add_task(),
                Ok(2) => self.view_tasks(),
                Ok(3) => self.remove_task(),
                Ok(4) => {
                    println!("Exiting...");
                    return;
                },
                _ => println!("Invalid choice. Please try again."),
            }
            println!(); // New line for better readability
        }
    }
}

fn main() {
    let mut app = TodoApp::new();
    app.run();
}