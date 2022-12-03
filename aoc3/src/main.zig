const std = @import("std");
const debug = std.debug;
const Timer = std.time.Timer;

const offset_low = 64;
const offset_high = 96;
const letter_count = 26;

pub fn solve1(input: []const u8) !u32 {
    var lines = std.mem.split(u8, input, "\n");
    var line_number: u32 = 0;
    var total_score: u32 = 0;

    while (lines.next()) |line| {
        if (std.mem.eql(u8, line, "")) continue;
        
        var score: u32 = 0;
        const half = line.len / 2;
        const first = line[0..half];
        const second = line[half..];
        var c: u8 = 0;

        for (first) |c1| {
            for (second) |c2| {
                if (c1 == c2) {
                    c = c1;
                    break;
                }
            }
        }

        if (c > offset_high) {
            score += c - offset_high;
        } else {
            score += c - offset_low + letter_count;
        }

        line_number += 1;
        total_score += score;
    }
    
    return total_score;
}

pub fn solve2(input: []const u8) !u32 {
    var lines = std.mem.split(u8, input, "\n");
    
    var total_score: u32 = 0;
    
    while (true)
    {
        var score: u32 = 0;
        
        const first = lines.next() orelse break;
        const second = lines.next() orelse break;
        const third = lines.next() orelse break;
        
        var c: u8 = 0;
        
        for (first) |c1| {
            for (second) |c2| {
                for (third) |c3| {
                   if (c1 == c2 and c2 == c3) {
                        c = c1;
                        break;
                    } 
                } 
            }
        }
        
        if (c > offset_high) {
            score += c - offset_high;
        } else {
            score += c - offset_low + letter_count;
        }
        
        total_score += score;
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
