const std = @import("std");
const utils = @import("utils.zig");
const print = std.debug.print;
const expectEqual = std.testing.expectEqual;
const TokenIterator = std.mem.TokenIterator;

pub fn main() void {
    print("\nDay 5: A Maze of Twisty Trampolines, All Alike\n", .{});
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n", .{});

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const data = utils.readFile(allocator, "input/05/input");
    defer allocator.free(data);

    var arraylist = createArrayList(allocator, data);
    defer arraylist.deinit();

    // Part 1
    print("Part 1: {d}\n", .{jumper(arraylist)});
}

fn createArrayList(
    allocator: std.mem.Allocator,
    data: []const u8,
) std.array_list.Managed(i32) {
    var arraylist = std.array_list.Managed(i32).init(allocator);
    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        const num = std.fmt.parseInt(i32, line, 10) catch |err| {
            std.debug.panic("Error parsing number: {}", .{err});
        };
        arraylist.append(num) catch |err| {
            std.debug.panic("Error appending number: {}", .{err});
        };
    }
    return arraylist;
}

fn jumper(arraylist: std.array_list.Managed(i32)) u32 {
    var steps: u32 = 0;
    var index: isize = 0;
    const len = arraylist.items.len;
    while (index >= 0) {
        const idx: usize = @intCast(index);
        if (idx >= len) break;
        const jump = arraylist.items[idx];
        arraylist.items[idx] += 1;
        index, const overflow = @addWithOverflow(index, @as(isize, jump));
        if (overflow != 0 or index < 0) break;
        steps += 1;
    }
    return steps;
}

test "0 3 0 1 -3" {
    const lines = "0\n3\n0\n1\n-3";
    const allocator = std.testing.allocator;
    var arraylist = createArrayList(allocator, lines);
    defer arraylist.deinit();

    try expectEqual(5, arraylist.items.len);

    try expectEqual(0, arraylist.items[0]);
    try expectEqual(3, arraylist.items[1]);
    try expectEqual(0, arraylist.items[2]);
    try expectEqual(1, arraylist.items[3]);
    try expectEqual(-3, arraylist.items[4]);

    try expectEqual(5, jumper(arraylist));
}
