const std = @import("std");

const my_hand_offset: u8 = 88;
const your_hand_offset: u8 = 65;

const loses_to = [_]u8{ 2, 0, 1 };
const beats = [_]u8{ 1, 2, 0 };

fn solve(input: []const u8) !u32 {
    var total_score: u32 = 0;
    var split = std.mem.split(u8, input, "\n");

    while (split.next()) |line| {
        if (std.mem.eql(u8, line, "")) continue;

        const which = line[2] - my_hand_offset;
        const your_hand = line[0] - your_hand_offset;
        var my_hand: u8 = 0;

        if (which == 0) {
            my_hand = loses_to[your_hand];
        } else if (which == 1) {
            my_hand = your_hand;
        } else {
            my_hand = beats[your_hand];
        }

        var score: u8 = 0;
        if (loses_to[my_hand] == your_hand) {
            score = 6 + my_hand + 1;
        } else if (my_hand == your_hand) {
            score = 3 + my_hand + 1;
        } else {
            score = my_hand + 1;
        }

        total_score += score;
    }

    return total_score;
}

const Timer = std.time.Timer;

pub fn main() !void {
    const file = @embedFile("input.txt");
    var counter: u32 = 1000;
    var timer = try Timer.start();
    var time: u64 = 0;

    while (counter > 0) {
        _ = try solve(file);
        time += timer.lap();
        counter -= 1;
    }

    std.debug.print("ns: {}\n", .{time / 1000});
}

test "test" {
    const file = @embedFile("input.txt");
    var counter: u32 = 1000;
    var timer = try Timer.start();
    var time: u64 = 0;

    while (counter > 0) {
        _ = try solve(file);
        time += timer.lap();
        counter -= 1;
    }

    std.debug.print("ns: {}\n", .{time / 1000});
}
