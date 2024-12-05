-module(todo_app).
-export([start/0, run/0, add_task/1, view_tasks/0, remove_task/0, clear_all_tasks/0]).

-record(task, {description}).

start() ->
    % Load existing tasks from file
    case file:read_file("tasks.txt") of
        {ok, Content} ->
            Tasks = string:split(binary_to_list(Content), "\n", all),
            TaskRecords = [#task{description = Task} || Task <- Tasks, Task =/= ""],
            run(TaskRecords);
        _ ->
            run([])
    end.

run(Tasks) ->
    io:format("=== To-Do List ===~n"),
    io:format("1. Add Task~n"),
    io:format("2. View Tasks~n"),
    io:format("3. Remove Task~n"),
    io:format("4. Exit~n"),
    io:format("Choose an option: "),
    
    case io:get_line("") of
        "1\n" -> 
            NewTask = io:get_line("Enter the task description: "),
            NewTasks = add_task(Tasks, string:trim(NewTask)),
            save_tasks(NewTasks),
            run(NewTasks);
        "2\n" -> 
            view_tasks(Tasks),
            run(Tasks);
        "3\n" -> 
            NewTasks = remove_task(Tasks),
            save_tasks(NewTasks),
            run(NewTasks);
        "4\n" -> 
            io:format("Exiting...~n");
        _ -> 
            io:format("Invalid choice. Please try again.~n"),
            run(Tasks)
    end.

add_task(Tasks, Description) ->
    if
        Description =/= "" ->
            [#task{description = Description} | Tasks];
        true ->
            Tasks
    end.

view_tasks([]) ->
    io:format("No tasks available.~n");
view_tasks(Tasks) ->
    io:format("=== Your Tasks ===~n"),
    lists:foreach(fun(#task{description = Desc}, Index) ->
        io:format("~p. ~s~n", [Index + 1, Desc])
    end, lists:zip(Tasks)).

remove_task(Tasks) ->
    view_tasks(Tasks),
    case io:get_line("Enter the task number to remove (type 0 to remove all tasks): ") of
        "0\n" -> [];
        Input when is_list(Input) ->
            case string:to_integer(string:trim(Input)) of
                {ok, N} when N > 0, N =< length(Tasks) ->
                    lists:nthdel(N, Tasks);
                _ ->
                    io:format("Invalid task number.~n"),
                    Tasks
            end
    end.

save_tasks(Tasks) ->
    FileContent = lists:map(fun(#task{description = Desc}) -> Desc ++ "\n" end, Tasks),
    ok = file:write_file("tasks.txt", list_to_binary(FileContent)).