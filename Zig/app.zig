const std = @import("std");

const MAX_TASKS = 100;
const MAX_TASK_LENGTH = 256;
const FILE_NAME = "tasks.txt";

pub fn main() !void {
    var allocator = std.heap.page_allocator;
    var app = TodoApp{ .task_count = 0 };

    try app.loadTasks(allocator);
    
    while (true) {
        app.displayMenu();
        const choice = try std.io.getStdIn().readInt(u32);
        
        switch (choice) {
            1 => try app.addTask(allocator),
            2 => app.viewTasks(),
            3 => try app.removeTask(),
            4 => {
                std.debug.print("Exiting...\n", .{});
                return;
            },
            else => std.debug.print("Invalid choice. Please try again.\n", .{}),
        }
        std.debug.print("\n", .{});
    }
}

const TodoApp = struct {
    tasks: [MAX_TASKS][MAX_TASK_LENGTH]u8,
    task_count: usize,

    pub fn loadTasks(self: *TodoApp, allocator: *std.mem.Allocator) !void {
        const file = try std.fs.cwd().openFile(FILE_NAME, .{});
        defer file.close();

        var reader = file.reader();
        while (self.task_count < MAX_TASKS) {
            const line = try reader.readUntilDelimiterAlloc(allocator, '\n', 1024);
            if (line.len == 0) break; // End of file

            const task_len = std.mem.copy(u8, self.tasks[self.task_count][..], line);
            self.tasks[self.task_count][task_len] = 0; // Null-terminate
            self.task_count += 1;
        }
    }

    pub fn saveTasks(self: *TodoApp) !void {
        const file = try std.fs.cwd().createFile(FILE_NAME, .{ .write = true, .truncate = true });
        defer file.close();

        for (self.task_count) |i| {
            try file.writer().print("{s}\n", .{self.tasks[i]});
        }
    }

    pub fn displayMenu(self: *TodoApp) void {
        std.debug.print("=== To-Do List ===\n", .{});
        std.debug.print("1. Add Task\n", .{});
        std.debug.print("2. View Tasks\n", .{});
        std.debug.print("3. Remove Task\n", .{});
        std.debug.print("4. Exit\n", .{});
        std.debug.print("Choose an option: ", .{});
    }

    pub fn addTask(self: *TodoApp, allocator: *std.mem.Allocator) !void {
        if (self.task_count >= MAX_TASKS) {
            std.debug.print("Task limit reached. Cannot add more tasks.\n", .{});
            return;
        }

        std.debug.print("Enter the tasks separated by '/': ", .{});
        
        var input_buffer: [MAX_TASK_LENGTH * 10]u8 = undefined;
        const input_len = try std.io.getStdIn().readUntilDelimiter(&input_buffer, '\n', 1024);
        
        var token_start: usize = 0;
        for (input_buffer[0..input_len]) |c| {
            if (c == '/') {
                const task_len = token_start + @intCast(usize, &c - &input_buffer[token_start]);
                if (task_len > 0 && self.task_count < MAX_TASKS) {
                    self.tasks[self.task_count][..task_len] = input_buffer[token_start..task_len];
                    self.tasks[self.task_count][task_len] = 0; // Null-terminate
                    self.task_count += 1;
                }
                token_start += 1; // Skip the '/'
            }
            token_start += 1;
        }

        // Check for the last task after the last '/'
        if (token_start < input_len && self.task_count < MAX_TASKS) {
            const task_len = input_len - token_start;
            self.tasks[self.task_count][..task_len] = input_buffer[token_start..input_len];
            self.tasks[self.task_count][task_len] = 0; // Null-terminate
            self.task_count += 1;
        }

        try self.saveTasks();
        std.debug.print("Tasks added!\n", .{});
    }

    pub fn viewTasks(self: *TodoApp) void {
        if (self.task_count == 0) {
            std.debug.print("No tasks available.\n", .{});
            return;
        }

        std.debug.print("=== Your Tasks ===\n", .{});
        for (self.task_count) |i| {
            std.debug.print("{d}. {s}\n", .{i + 1, self.tasks[i]});
        }
    }

    pub fn removeTask(self: *TodoApp) !void {
        self.viewTasks();

        if (self.task_count == 0) return;

        std.debug.print("Enter the task number to remove (type 0 to remove all tasks): ", .{});
        
        const taskNumber = try std.io.getStdIn().readInt(u32);
        
        if (taskNumber > 0 && taskNumber <= @intCast(u32, self.task_count)) {
            for (taskNumber - 1 .. self.task_count - 1) |i| {
                self.tasks[i] = self.tasks[i + 1];
            }
            self.task_count -= 1;
            try self.saveTasks();
            std.debug.print("Task removed!\n", .{});
        } else if (taskNumber == 0) {
            self.task_count = 0; // Clear all tasks
            try self.saveTasks();
            std.debug.print("All tasks cleared!\n", .{});
        } else {
            std.debug.print("Invalid task number.\n", .{});
        }
    }
};