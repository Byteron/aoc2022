const std = @import("std");
const Timer = std.time.Timer;

pub fn solve1(input: []const u8) !u32 {
    var total_score: u32 = 0;
    
    var lines = std.mem.tokenize(u8, input, "\n\r");

    while (lines.next()) |line| {
        const half = line.len / 2;
        const first = line[0..half];
        const second = line[half..];
        const both = toBits(first) & toBits(second);
        const priority = @ctz(both) + 1;
        total_score += priority;
    }

    return total_score;
}

pub fn solve2(input: []const u8) !u32 {
    var total_score: u32 = 0;
    
    var lines = std.mem.tokenize(u8, input, "\n\r");
    
    while (true)
    {   
        const first = lines.next() orelse break;
        const second = lines.next() orelse break;
        const third = lines.next() orelse break;
        
        const all = toBits(first) & toBits(second) & toBits(third);
        const priority = @ctz(all) + 1;
        total_score += priority;
    }
    
    return total_score;
}

fn toBits(chars: []const u8) u64 {
    var bits: u64 = 0;
    for (chars) | c | {
        const bit: u64 = if (c >= 'A' and c <= 'Z') (26 + c - 'A') else (c - 'a');
        bits |= @as(u64, 1) << @intCast(u6, bit);
    }
    return bits;
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
