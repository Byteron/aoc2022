const std = @import("std");
const Timer = std.time.Timer;
const ArrayList = std.ArrayList;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const test_runs = 1;

const Stack = struct {
    array: [100]u8 = [_]u8{0} ** 100,
    len: u8 = 0,

    pub fn push(self: *Stack, item: u8) void {
        self.array[self.len] = item;
        self.len += 1;
    }
    
    pub fn push_front(self: *Stack, item: u8) void {
        var index: u8 = self.len;
        while (index > 0) {
            self.array[index] = self.array[index - 1];
            index -= 1;
        }
        self.array[0] = item;
        self.len += 1;
    }
    
    pub fn pop(self: *Stack) u8 {
        self.len -= 1;
        return self.array[self.len];
    }
    
    pub fn peek(self: *const Stack) u8 {
        return self.array[self.len - 1];
    }
};

pub fn solve1(input: []const u8) !void {
    var lines = std.mem.split(u8, input, "\n\n");
    
    const table = lines.next().?;
    const moves = lines.next().?;
    
    var stacks = [_]Stack{Stack{}} ** 9;
    
    var rows = std.mem.split(u8, table, "\n");
    
    while(rows.next()) |row| {
        if (std.mem.eql(u8, row[1..2], "1")) break;
        
        var index: u8 = 0;
        while (index < 9)
        {
            const char_index = index * 4 + 1;
            const char = row[char_index];
            if (std.mem.eql(u8, row[char_index..char_index+1], " ")) {
                index += 1;
                continue;   
            }
            stacks[index].push_front(char);
            index += 1;
        }
    }
    
    var commands = std.mem.split(u8, moves, "\n");
    
    while (commands.next()) |command| {
        if (std.mem.eql(u8, command, "")) break;
        
        var split = std.mem.tokenize(u8, command, "move from to");
        
        const count = try std.fmt.parseInt(u8, split.next().?, 10);
        const from = try std.fmt.parseInt(u8, split.next().?, 10);
        const to = try std.fmt.parseInt(u8, split.next().?, 10);
        
        var index : u8 = 0;
        while (index < count)
        {
            const value = stacks[from - 1].pop();
            stacks[to - 1].push(value);
            index += 1;
        }
    }
    
    for (stacks) |stack| {
        std.debug.print("{c}\n", .{ stack.peek() });
    }
}

pub fn solve2(input: []const u8) !void {
    var lines = std.mem.split(u8, input, "\n\n");
    
    const table = lines.next().?;
    const moves = lines.next().?;
    
    var stacks = [_]Stack{Stack{}} ** 9;
    
    var rows = std.mem.split(u8, table, "\n");
    
    while(rows.next()) |row| {
        if (std.mem.eql(u8, row[1..2], "1")) break;
        
        var index: u8 = 0;
        while (index < 9)
        {
            const char_index = index * 4 + 1;
            const char = row[char_index];
            if (std.mem.eql(u8, row[char_index..char_index+1], " ")) {
                index += 1;
                continue;   
            }
            stacks[index].push_front(char);
            index += 1;
        }
    }
    
    var commands = std.mem.split(u8, moves, "\n");
    
    while (commands.next()) |command| {
        if (std.mem.eql(u8, command, "")) break;
        
        var split = std.mem.tokenize(u8, command, "move from to");
        
        const count = try std.fmt.parseInt(u8, split.next().?, 10);
        const from = try std.fmt.parseInt(u8, split.next().?, 10);
        const to = try std.fmt.parseInt(u8, split.next().?, 10);
        
        
        var temp_stack = Stack{};
        var index : u8 = 0;
        while (index < count) {
            const value = stacks[from - 1].pop();
            temp_stack.push(value);
            index += 1;
        }
        
        index = 0;
        while (index < count)
        {
            const value = temp_stack.pop();
            stacks[to - 1].push(value);
            index += 1;
        }
    }
    
    for (stacks) |stack| {
        std.debug.print("{c}\n", .{ stack.peek() });
    }
}

pub fn bench(comptime solve: fn ([] const u8) anyerror!void) !void {
    const input = @embedFile("input.txt");
    var counter: u32 = test_runs;
    var timer = try Timer.start();
    var time: u64 = 0;
    
    while (counter > 0) {
        try solve(input);
        time += timer.lap();
        counter -= 1;
    }
    
    std.debug.print("ns: {}\n", .{time / test_runs});
}

pub fn main() !void {
    try bench(solve1);
    try bench(solve2);
    defer _ = gpa.deinit();
}

test {
    try bench(solve1);
    try bench(solve2);
    defer _ = gpa.deinit();
}