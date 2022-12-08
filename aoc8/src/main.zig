const std = @import("std");
const Timer = std.time.Timer;
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

const Data = struct {
    width: usize,
    height: usize,
    trees: ArrayList(u8),
};

fn parse(alloc: Allocator, input: []const u8) !Data {
    var data = Data{
        .width = 0,
        .height = 0,
        .trees = ArrayList(u8).init(alloc),
    };

    var lines = std.mem.tokenize(u8, input, "\n\r");

    while (lines.next()) |line| {
        data.width = line.len;
        data.height += 1;
    }

    try data.trees.ensureTotalCapacity(data.width * data.height);

    lines.reset();

    while (lines.next()) |line| {
        for (line) |c| {
            try data.trees.append(c - '0');
        }
    }

    return data;
}

fn solve1(data: *Data) !u32 {
    var total_score: u32 = 0;

    var x: usize = 0;
    while (x < data.width) : (x += 1) {
        var y: usize = 0;
        while (y < data.height) : (y += 1) {
            if (isTreeVisible(data, x, y)) total_score += 1;
        }
    }
    return total_score;
}

fn solve2(data: *Data) !u32 {
    var total_score: u32 = 0;

    var x: usize = 0;
    while (x < data.width) : (x += 1) {
        var y: usize = 0;
        while (y < data.height) : (y += 1) {
            const score = getScenicScore(data, x, y);
            if (score > total_score) total_score = score;
        }
    }

    return total_score;
}

fn isTreeVisible(data: *Data, x: usize, y: usize) bool {
    if (x == 0 or y == 0 or x == data.width - 1 or y == data.height - 1) return true;

    var index = y * data.width + x;
    var height = data.trees.items[index];

    var nx: usize = x - 1;
    var visible_left = while (true) {
        var nindex = y * data.width + nx;
        var nheight = data.trees.items[nindex];
        if (nheight >= height) break false;
        if (nx == 0) break true;
        nx -= 1;
    };

    if (visible_left) return true;

    nx = x + 1;
    var visible_right = while (true) {
        var nindex = y * data.width + nx;
        if (data.trees.items[nindex] >= height) break false;
        if (nx == data.width - 1) break true;
        nx += 1;
    };

    if (visible_right) return true;

    var ny: usize = y - 1;
    var visible_top = while (true) {
        var nindex = ny * data.width + x;
        var nheight = data.trees.items[nindex];
        if (nheight >= height) break false;
        if (ny == 0) break true;
        ny -= 1;
    };

    if (visible_top) return true;

    ny = y + 1;
    var visible_bottom = while (true) {
        var nindex = ny * data.width + x;
        if (data.trees.items[nindex] >= height) break false;
        if (ny == data.height - 1) break true;
        ny += 1;
    };

    return visible_bottom;
}

fn getScenicScore(data: *Data, x: usize, y: usize) u32 {
    if (x == 0 or y == 0 or x == data.width - 1 or y == data.height - 1) return 0;

    var index = y * data.width + x;
    var height = data.trees.items[index];

    var nx: usize = x - 1;
    var scenic_left: usize = while (true) {
        var nindex = y * data.width + nx;
        var nheight = data.trees.items[nindex];
        if (nheight >= height) break x - nx;
        if (nx == 0) break x;
        nx -= 1;
    };

    nx = x + 1;
    var scenic_right: usize = while (true) {
        var nindex = y * data.width + nx;
        if (data.trees.items[nindex] >= height) break nx - x;
        if (nx == data.width - 1) break data.width - 1 - x;
        nx += 1;
    };

    var ny: usize = y - 1;
    var scenic_top: usize = while (true) {
        var nindex = ny * data.width + x;
        var nheight = data.trees.items[nindex];
        if (nheight >= height) break y - ny;
        if (ny == 0) break y;
        ny -= 1;
    };

    ny = y + 1;
    var scenic_bottom: usize = while (true) {
        var nindex = ny * data.width + x;
        if (data.trees.items[nindex] >= height) break ny - y;
        if (ny == data.height - 1) break data.height - 1 - y;
        ny += 1;
    };

    // std.debug.print("{}, {}, {}, {}\n", .{ scenic_left, scenic_right, scenic_top, scenic_bottom });

    return @intCast(u32, scenic_left * scenic_right * scenic_top * scenic_bottom);
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

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var data = try parse(alloc, input);
    defer data.trees.deinit();

    try bench(solve1, &data);
    try bench(solve2, &data);
}

test {
    const input = @embedFile("input.txt");

    var data = try parse(std.testing.allocator, input);
    defer data.trees.deinit();

    var score1 = try solve1(&data);
    var score2 = try solve2(&data);

    std.debug.print("Score: {d}\n", .{score1});
    std.debug.print("Score: {d}\n", .{score2});
}
