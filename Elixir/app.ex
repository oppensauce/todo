defmodule TodoApp do
  @file_name "tasks.txt"

  def start do
    tasks = load_tasks()
    run(tasks)
  end

  defp run(tasks) do
    IO.puts("=== To-Do List ===")
    IO.puts("1. Add Task")
    IO.puts("2. View Tasks")
    IO.puts("3. Remove Task")
    IO.puts("4. Exit")
    IO.write("Choose an option: ")

    case IO.gets("") |> String.trim() do
      "1" -> 
        tasks = add_task(tasks)
        save_tasks(tasks)
        run(tasks)

      "2" -> 
        view_tasks(tasks)
        run(tasks)

      "3" -> 
        tasks = remove_task(tasks)
        save_tasks(tasks)
        run(tasks)

      "4" -> 
        IO.puts("Exiting...")

      _ -> 
        IO.puts("Invalid choice. Please try again.")
        run(tasks)
    end
  end

  defp add_task(tasks) do
    IO.write("Enter the task description: ")
    task_description = IO.gets("") |> String.trim()

    if task_description != "" do
      [task_description | tasks]
    else
      tasks
    end
  end

  defp view_tasks([]) do
    IO.puts("No tasks available.")
  end
  
  defp view_tasks(tasks) do
    IO.puts("=== Your Tasks ===")
    Enum.each_with_index(tasks, fn task, index ->
      IO.puts("#{index + 1}. #{task}")
    end)
  end

  defp remove_task(tasks) do
    view_tasks(tasks)

    IO.write("Enter the task number to remove (type 0 to remove all tasks): ")
    
    case IO.gets("") |> String.trim() do
      "0" -> []
      
      input when input =~ ~r/^\d+$/ ->
        task_number = String.to_integer(input)

        if task_number > 0 and task_number <= length(tasks) do
          List.delete_at(tasks, task_number - 1)
        else
          IO.puts("Invalid task number.")
          tasks
        end

      _ ->
        IO.puts("Invalid input.")
        tasks
    end
  end

  defp save_tasks(tasks) do
    File.write!(@file_name, Enum.join(tasks, "\n"))
  end

  defp load_tasks do
    case File.read(@file_name) do
      {:ok, content} ->
        String.split(content, "\n", trim: true)

      {:error, _reason} ->
        []
    end
  end
end

# To run the application, use the following command in the Elixir shell:
# TodoApp.start()