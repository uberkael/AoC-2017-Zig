const std = @import("std");
const utils = @import("utils.zig");
const print = std.debug.print;
const expectEqual = std.testing.expectEqual;
const TokenIterator = std.mem.TokenIterator;

pub fn main() void {
    print("\nDay 2: Corruption Checksum\n", .{});
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const data = utils.readFile(allocator, "input/02/input");
    defer allocator.free(data);
    var lines = std.mem.tokenizeScalar(u8, data, '\n');

    // Part 1
    print("Part 1: {}\n", .{checksum(allocator, &lines)});
}

/// Calculates the checksum of the spreadsheet (list of rows)
fn checksum(
    allocator: std.mem.Allocator,
    lines: *std.mem.TokenIterator(u8, .scalar),
) u32 {
    var sum: u32 = 0;
    while (lines.next()) |line| {
        var nums = utils.parseToNums(allocator, line, '\t');
        defer nums.deinit();
        sum += Row.init(nums.items).difference();
    }
    return sum;
}

const Row = struct {
    max: u32,
    min: u32,
    /// Calculates the max and min of the row
    fn init(data: []const u32) Row {
        var max_val: u32 = 0;
        var min_val: u32 = std.math.maxInt(u32);
        for (data) |val| {
            if (val > max_val) max_val = val;
            if (val < min_val) min_val = val;
        }
        return Row{ .max = max_val, .min = min_val };
    }
    /// Returns the difference between max and min
    fn difference(self: Row) u32 {
        return self.max - self.min;
    }
};

test "5 1 9 5 difference is 8" {
    try expectEqual(Row.init(&[_]u32{ 5, 1, 9 }).difference(), 8);
}
test "7 5 3 difference is 4" {
    try expectEqual(Row.init(&[_]u32{ 7, 5, 3 }).difference(), 4);
}
test "2 4 6 8 difference is 6" {
    try expectEqual(Row.init(&[_]u32{ 2, 4, 6, 8 }).difference(), 6);
}
test "spreadsheet's checksum is 18" {
    const allocator = std.testing.allocator;
    const data = "5\t1\t9\t5\n7\t5\t3\n2\t4\t6\t8";
    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    try expectEqual(checksum(allocator, &lines), 18);
}
