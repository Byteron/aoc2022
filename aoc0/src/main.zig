const std = @import("std");
const Timer = std.time.Timer;

const Data = struct {};

fn parse(input: []const u8) !Data {
    var data = Data{};

    var lines = std.mem.tokenize(u8, input, "\n\r");

    while (lines.next()) |line| {
        std.debug.print("{s}\n", .{line});
    }

    return data;
}

fn solve1(data: *Data) !u32 {
    var total_score: u32 = 0;
    _ = data;
    return total_score;
}

fn solve2(data: *Data) !u32 {
    var total_score: u32 = 0;
    _ = data;
    return total_score;
}

fn bench(comptime solve: fn (*Data) anyerror!u32, data: *Data) !void {
    var counter: u32 = 1000;
    var timer = try Timer.start();
    var time: u64 = 0;

    while (counter > 0) {
        _ = try solve(data);
        time += timer.lap();
        counter -= 1;
    }

    std.debug.print("ns: {}\n", .{time / 1000});
}

pub fn main() !void {
    const input = @embedFile("input.txt");

    // allocator?

    var data = try parse(input);

    try bench(solve1, &data);
    try bench(solve2, &data);
}

test {
    const input = @embedFile("input.txt");

    // allocator?

    var data = try parse(input);

    var score1 = try solve1(&data);
    var score2 = try solve2(&data);

    std.debug.print("Score: {d}\n", .{score1});
    std.debug.print("Score: {d}\n", .{score2});
}
