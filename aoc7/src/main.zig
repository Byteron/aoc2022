const std = @import("std");
const Timer = std.time.Timer;
const Allocator = std.mem.Allocator;
const HashMap = std.StringHashMap;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const test_count: u32 = 1000;

const ItemType = enum {
    file,
    directory,
};

const Item = struct {
    item_type: ItemType,
    name: []const u8,
    size: u32,
    parent: *Item,
    children: HashMap(Item),

    fn init(alloc: Allocator, parent: *Item, item_type: ItemType, name: []const u8, size: u32) Item {
        return Item {
            .item_type = item_type,
            .name = name,
            .size = size,
            .parent = parent,
            .children = HashMap(Item).init(alloc),
        };
    }

    fn deinit(self: *Item, alloc: Allocator) void {
        var it = self.children.valueIterator();
        
        while (it.next()) |item| {
            item.deinit(alloc);
        }

        self.children.deinit();
    }
    
    fn calculate(self: *Item) u32 {
        if (self.item_type == .file) return self.size;
        
        self.size = 0;
        var it = self.children.valueIterator();
        while (it.next()) |item| {
            self.size += item.calculate();
        }
        return self.size;
    }
    
    fn total_size(self: *const Item, limit: u32) u32 {
        var sum: u32 = 0;
        if (self.size <= limit and self.item_type == .directory) sum += self.size;
        
        var it = self.children.valueIterator();
        while (it.next()) |item| {
            sum += item.total_size(limit);
        }
        
        return sum;
    }
    
    fn find_dir_to_delete(self: *const Item, needed_space: u32) u32 {
        var size: u32 = 0;
        if (self.size >= needed_space and self.item_type == .directory) size = self.size;
        
        var it = self.children.valueIterator();
        while (it.next()) |item| {
            var other_size = item.find_dir_to_delete(needed_space);
            if (other_size > needed_space and other_size < size) {
                size = other_size;
            }
        }
        
        return size;
    }
};

const Tree = struct {
    alloc: Allocator,

    root: *Item,
    current: *Item,

    fn init(alloc: Allocator) !Tree {
        var root = try alloc.create(Item);
        root.* = Item.init(alloc, undefined, .directory, "/", 0);

        return Tree {
            .alloc = alloc,
            .root = root,
            .current = root,
        };
    }
    
    fn deinit(self: *Tree) void {
        self.root.deinit(self.alloc);
        self.alloc.destroy(self.root);
    }

    fn has(self: *Tree, name: []const u8) bool {
        self.current.children.contains(name);
    }

    fn mkdir(self: *Tree, name: []const u8) !void {
        if (self.current.children.contains(name)) return;
        var item = Item.init(self.alloc, self.current, .directory, name, 0);
        try self.current.children.put(name, item);
    }

    fn touch(self: *Tree, name: []const u8, size: u32) !void {
        if (self.current.children.contains(name)) return;
        var item = Item.init(self.alloc, self.current, .file, name, size);
        try self.current.children.put(name, item);
    }

    fn move(self: *Tree, name: []const u8) void {
        self.current = self.current.children.getPtr(name) orelse return;
    }

    fn back(self: *Tree) void {
        self.current = self.current.parent;
    }
};

fn solve1(input: []const u8) !u32 {
    var tokens = std.mem.tokenize(u8, input, " \n\r");
    
    var tree = try Tree.init(allocator);
    defer tree.deinit();
    
    while (tokens.next()) |token| {
        if (std.mem.eql(u8, token, "$")) {
            const command = tokens.next().?;
            
            if (std.mem.eql(u8, command, "ls")) {
                while (!std.mem.eql(u8, tokens.peek() orelse break, "$")) {
                    var type_string = tokens.next() orelse break;
                    var name = tokens.next() orelse break;
                    var size: u32 = 0;
                    
                    if (std.mem.eql(u8, type_string, "dir")) {
                        try tree.mkdir(name);
                    } else {
                        size = try std.fmt.parseInt(u32, type_string, 10);
                        try tree.touch(name, size);
                    }
                }
            }
            else if (std.mem.eql(u8, command, "cd")) {
                var dir = tokens.next() orelse break;
                
                if (std.mem.eql(u8, dir, "..")) {
                    tree.back();
                } else {
                    tree.move(dir);
                }
            }
        }
    }
    
    _ = tree.root.calculate();
    return tree.root.total_size(100000);
}

fn solve2(input: []const u8) !u32 {
    var tokens = std.mem.tokenize(u8, input, " \n\r");
    
    var tree = try Tree.init(allocator);
    defer tree.deinit();
    
    while (tokens.next()) |token| {
        if (std.mem.eql(u8, token, "$")) {
            const command = tokens.next().?;
            
            if (std.mem.eql(u8, command, "ls")) {
                while (!std.mem.eql(u8, tokens.peek() orelse break, "$")) {
                    var type_string = tokens.next() orelse break;
                    var name = tokens.next() orelse break;
                    var size: u32 = 0;
                    
                    if (std.mem.eql(u8, type_string, "dir")) {
                        try tree.mkdir(name);
                    } else {
                        size = try std.fmt.parseInt(u32, type_string, 10);
                        try tree.touch(name, size);
                    }
                }
            }
            else if (std.mem.eql(u8, command, "cd")) {
                var dir = tokens.next() orelse break;
                
                if (std.mem.eql(u8, dir, "..")) {
                    tree.back();
                } else {
                    tree.move(dir);
                }
            }
        }
    }
    
    _ = tree.root.calculate();
    
    const used_space = tree.root.size;
    const free_space = 70000000 - used_space;
    const needed_space = 30000000 - free_space;
    
    return tree.root.find_dir_to_delete(needed_space);
}

fn bench(comptime solve: fn ([] const u8) anyerror!u32) !void {
    const input = @embedFile("input.txt");
    var counter: u32 = test_count;
    var timer = try Timer.start();
    var time: u64 = 0;
    var score: u32 = 0;
    
    while (counter > 0) {
        score = try solve(input);
        time += timer.lap();
        counter -= 1;
    }

    std.debug.print("Score: {d}\n", .{score});
    std.debug.print("ns: {}\n", .{time / test_count});
}

pub fn main() !void {
    try bench(solve1);
    try bench(solve2);
    _ = gpa.deinit();
}

test {
    try bench(solve1);
    try bench(solve2);
    _ = gpa.deinit();
}
