const std = @import("std");
const utils = @import("utils.zig");
const print = std.debug.print;
const expectEqual = std.testing.expectEqual;
const TokenIterator = std.mem.TokenIterator;

pub fn main() void {
    print("\nDay 2: Corruption Checksum\n", .{});
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━\n", .{});

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const data = utils.readFile(allocator, "input/02/input");
    defer allocator.free(data);
    var lines = std.mem.tokenizeScalar(u8, data, '\n');

    // Part 1
    print("Part 1: {}\n", .{checksum(allocator, &lines, difference)});
    // Reset iterator
    lines = std.mem.tokenizeScalar(u8, data, '\n');
    // Part 2
    print("Part 2: {}\n", .{checksum(allocator, &lines, division)});
}

/// Calculates the checksum of the spreadsheet (list of rows)
fn checksum(
    allocator: std.mem.Allocator,
    lines: *std.mem.TokenIterator(u8, .scalar),
    sumFunc: fn ([]const u32) u32,
) u32 {
    var sum: u32 = 0;
    while (lines.next()) |line| {
        var nums = utils.parseToNums(allocator, line, '\t');
        defer nums.deinit();
        sum += sumFunc(nums.items);
    }
    return sum;
}

/// Find max and min of a row and return the difference
fn difference(data: []const u32) u32 {
    var max: u32 = 0;
    var min: u32 = std.math.maxInt(u32);
    for (data) |val| {
        if (val > max) max = val;
        if (val < min) min = val;
    }
    return max - min;
}

test "5 1 9 5 difference is 8" {
    try expectEqual(difference(&[_]u32{ 5, 1, 9 }), 8);
}
test "7 5 3 difference is 4" {
    try expectEqual(difference(&[_]u32{ 7, 5, 3 }), 4);
}
test "2 4 6 8 difference is 6" {
    try expectEqual(difference(&[_]u32{ 2, 4, 6, 8 }), 6);
}
test "spreadsheet's checksum is 18" {
    const allocator = std.testing.allocator;
    const data = "5\t1\t9\t5\n7\t5\t3\n2\t4\t6\t8";
    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    try expectEqual(checksum(allocator, &lines, difference), 18);
}

////////////
// Part 2 //
////////////
/// Find two numbers of a row that evenly divide and return the result
fn division(data: []const u32) u32 {
    for (0..data.len) |i| {
        const a = data[i];
        for (i + 1..data.len) |j| {
            const b = data[j];
            if (a % b == 0) return a / b;
            if (b % a == 0) return b / a;
        }
    }
    return 0;
}

// In the first row, the only two numbers that evenly divide are 8 and 2;
// the result of this division is 4.
test "5 9 2 8 result 4" {
    try expectEqual(4, division(&[_]u32{ 5, 9, 2, 8 }));
}
// In the second row, the two numbers are 9 and 3; the result is 3.
test "9 4 7 3 result 3" {
    try expectEqual(3, division(&[_]u32{ 9, 4, 7, 3 }));
}
// In the third row, the result is 2.
test "3 8 6 5 result 2" {
    try expectEqual(2, division(&[_]u32{ 3, 8, 6, 5 }));
}
test "spreadsheet's checksum2 is 9" {
    const allocator = std.testing.allocator;
    const data = "5\t9\t2\t8\n9\t4\t7\t3\n3\t8\t6\t5";
    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    try expectEqual(checksum(allocator, &lines, division), 9);
}
