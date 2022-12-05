const std = @import("std");
const Timer = std.time.Timer;

const test_runs = 1;

const stack_image_len = 34;
const stack_step_len = 4;
const stack_first_index = 1;
const stack_count = 9;

pub fn solve1(input: []const u8) !u32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    
    var total_score: u32 = 0;
    
    var lines = std.mem.split(u8, input, "\n\n");
    
    const table = lines.next().?;
    const moves = lines.next().?;
    
    std.debug.print("Table:\n{s}\n", .{ table });
    std.debug.print("Moves:\n{s}\n", .{ moves });
    
    var stacks = std.ArrayList(std.ArrayList(u8)).init(allocator);
    defer stacks.deinit();
    
    var index: u8 = 0;
    
    while(index < stack_count) {
        try stacks.append(std.ArrayList(u8).init(allocator));
        index += 1;
    }
    
    var rows = std.mem.split(u8, table, "\n");
    
    while(rows.next()) |row| {
        if (std.mem.eql(u8, row[0..1], " ")) break;
    }

    
    
    
    // while (lines.next()) |line| {
    //     // if (std.mem.eql(u8, line, "")) break;
        
    //     std.debug.print("{s}\n", .{ line });
    // }
    
    // for (stacks.items) |stack| {
    //     stack.deinit();
    // }
    
    return total_score;
}

pub fn solve2(input: []const u8) !u32 {
    var total_score: u32 = 0;
    
    var lines = std.mem.tokenize(u8, input, "\n\r");
    
    while (lines.next()) |line| {
        std.debug.print("{s}\n", .{ line });
    }
    
    return total_score;
}

pub fn bench(comptime solve: fn ([] const u8) anyerror!u32) !void {
    const input = @embedFile("input.txt");
    var counter: u32 = test_runs;
    var timer = try Timer.start();
    var time: u64 = 0;
    var score: u32 = 0;
    
    while (counter > 0) {
        score = try solve(input);
        time += timer.lap();
        counter -= 1;
    }

    std.debug.print("Score: {d}\n", .{score});
    std.debug.print("ns: {}\n", .{time / test_runs});
}

pub fn main() !void {
    try bench(solve1);
    // try bench(solve2);
}

test {
    try bench(solve1);
    // try bench(solve2);
}
