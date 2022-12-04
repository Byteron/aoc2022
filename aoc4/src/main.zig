const std = @import("std");
const Timer = std.time.Timer;

pub fn solve1(input: []const u8) !u32 {
    var total_score: u32 = 0;
    
    var lines = std.mem.tokenize(u8, input, "\n\r");

    while (lines.next()) |line| {    
        var ranges = std.mem.tokenize(u8, line, ",");
        var range1 = ranges.next() orelse break;
        var range2 = ranges.next() orelse break;
        
        var numbers1 = std.mem.tokenize(u8, range1, "-");
        var numbers2 = std.mem.tokenize(u8, range2, "-");
        
        var snumber1 = numbers1.next() orelse break;
        var snumber2 = numbers1.next() orelse break;
        
        var snumber3 = numbers2.next() orelse break;
        var snumber4 = numbers2.next() orelse break;
        
        var number1 = try std.fmt.parseInt(u8, snumber1, 10);
        var number2 = try std.fmt.parseInt(u8, snumber2, 10);
        var number3 = try std.fmt.parseInt(u8, snumber3, 10);
        var number4 = try std.fmt.parseInt(u8, snumber4, 10);
        
        if (number1 <= number3 and number2 >= number4 or
            number3 <= number1 and number4 >= number2) {
                total_score += 1;
        }
    }

    return total_score;
}

pub fn solve2(input: []const u8) !u32 {
    var total_score: u32 = 0;
    
    var lines = std.mem.tokenize(u8, input, "\n\r");
    
    while (lines.next()) |line| {
        var ranges = std.mem.tokenize(u8, line, ",");
        var range1 = ranges.next() orelse break;
        var range2 = ranges.next() orelse break;
        
        var numbers1 = std.mem.tokenize(u8, range1, "-");
        var numbers2 = std.mem.tokenize(u8, range2, "-");
        
        var snumber1 = numbers1.next() orelse break;
        var snumber2 = numbers1.next() orelse break;
        
        var snumber3 = numbers2.next() orelse break;
        var snumber4 = numbers2.next() orelse break;
        
        var small1 = try std.fmt.parseInt(u8, snumber1, 10);
        var big1 = try std.fmt.parseInt(u8, snumber2, 10);
        var small2 = try std.fmt.parseInt(u8, snumber3, 10);
        var big2 = try std.fmt.parseInt(u8, snumber4, 10);
        
        if (big1 < small2 or big2 < small1) { continue; }
        total_score += 1;
        
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
