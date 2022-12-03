const std = @import("std");
const Timer = std.time.Timer;

pub fn solve1(input: []const u8) !u32 {
    var total_score: u32 = 0;
    
    var lines = std.mem.tokenize(u8, input, "\n\r");

    while (lines.next()) |line| {
        std.debug.print("{s}", .{ line });
    }

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
    var counter: u32 = 1000;
    var timer = try Timer.start();
    var time: u64 = 0;
    var score: u32 = 0;
    
    while (counter > 0) {
        score = try solve(input);
        time += timer.lap();
        counter -= 1;
    }

    std.debug.print("Score: {d}\n", .{score});
    std.debug.print("ns: {}\n", .{time / 1000});
}

pub fn main() !void {
    try bench(solve1);
    try bench(solve2);
}

test {
    try bench(solve1);
    try bench(solve2);
}
