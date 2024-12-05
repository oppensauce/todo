using System;
using System.Collections.Generic;
using System.IO;

class TodoApp
{
    private List<string> tasks = new List<string>();
    private const string FILE_NAME = "tasks.txt";

    public TodoApp()
    {
        LoadTasks();
    }

    public void DisplayMenu()
    {
        Console.WriteLine("=== To-Do List ===");
        Console.WriteLine("1. Add Task");
        Console.WriteLine("2. View Tasks");
        Console.WriteLine("3. Remove Task");
        Console.WriteLine("4. Exit");
        Console.Write("Choose an option: ");
    }

    public void AddTask()
    {
        Console.Write("Enter the tasks separated by '/': ");
        string input = Console.ReadLine();
        var newTasks = input.Split(new[] { '/' }, StringSplitOptions.RemoveEmptyEntries);

        foreach (var task in newTasks)
        {
            string trimmedTask = task.Trim();
            if (!string.IsNullOrEmpty(trimmedTask))
            {
                tasks.Add(trimmedTask);
            }
        }

        SaveTasks();
        Console.WriteLine("Tasks added!");
    }

    public void ViewTasks()
    {
        if (tasks.Count == 0)
        {
            Console.WriteLine("No tasks available.");
            return;
        }

        Console.WriteLine("=== Your Tasks ===");
        for (int i = 0; i < tasks.Count; i++)
        {
            Console.WriteLine($"{i + 1}. {tasks[i]}");
        }
    }

    public void RemoveTask()
    {
        ViewTasks();
        
        if (tasks.Count == 0) return;

        Console.Write("Enter the task number to remove (type 0 to remove all tasks): ");
        if (int.TryParse(Console.ReadLine(), out int taskNumber))
        {
            if (taskNumber > 0 && taskNumber <= tasks.Count)
            {
                tasks.RemoveAt(taskNumber - 1);
                SaveTasks();
                Console.WriteLine("Task removed!");
            }
            else if (taskNumber == 0)
            {
                ClearAllTasks();
            }
            else
            {
                Console.WriteLine("Invalid task number.");
            }
        }
        else
        {
            Console.WriteLine("Invalid input.");
        }
    }

    public void ClearAllTasks()
    {
        tasks.Clear();
        SaveTasks();
        Console.WriteLine("All tasks cleared!");
    }

    private void SaveTasks()
    {
        File.WriteAllLines(FILE_NAME, tasks);
    }

    private void LoadTasks()
    {
        if (File.Exists(FILE_NAME))
        {
            tasks.AddRange(File.ReadAllLines(FILE_NAME));
        }
    }

    public void Run()
    {
        while (true)
        {
            DisplayMenu();
            string choice = Console.ReadLine();

            switch (choice)
            {
                case "1":
                    AddTask();
                    break;
                case "2":
                    ViewTasks();
                    break;
                case "3":
                    RemoveTask();
                    break;
                case "4":
                    Console.WriteLine("Exiting...");
                    return;
                default:
                    Console.WriteLine("Invalid choice. Please try again.");
                    break;
            }
            Console.WriteLine();
        }
    }

    static void Main(string[] args)
    {
        TodoApp app = new TodoApp();
        app.Run();
    }
}