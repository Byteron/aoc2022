const std = @import("std");
const Timer = std.time.Timer;

pub fn solve(input: []const u8, count: u8) !u32 {
    var lines = std.mem.tokenize(u8, input, "\n\r");
    var line = lines.next().?;
    
    var bits: u64 = 0;
    var bit_count: u32 = 0;
    var prev_count: u32 = 0;
    var index: u32 = 0;
    while (bit_count < count) {
        const c = line[index];
        const bit: u64 = @as(u64, 1) << @intCast(u6, (c - 'a'));
        bits |= bit;
        bit_count = @popCount(bits);
        if (bit_count == prev_count) {
            index -= prev_count;
            bits = 0;
            prev_count = 0;
        }
        else {
            prev_count = bit_count;
        }
        index += 1;
    }

    return index;
}

pub fn bench(comptime solvefn: fn ([] const u8, count: u8) anyerror!u32, count: u8) !void {
    const input = @embedFile("input.txt");
    var counter: u32 = 1000;
    var timer = try Timer.start();
    var time: u64 = 0;
    var score: u32 = 0;
    
    while (counter > 0) {
        score = try solvefn(input, count);
        time += timer.lap();
        counter -= 1;
    }

    std.debug.print("Score: {d}\n", .{score});
    std.debug.print("ns: {}\n", .{time / 1000});
}

pub fn main() !void {
    try bench(solve, 4);
    try bench(solve, 14);
}

test {
    try bench(solve, 4);
    try bench(solve, 14);
}
