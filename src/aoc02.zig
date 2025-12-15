const std = @import("std");
const utils = @import("utils.zig");
const print = std.debug.print;
const expectEqual = std.testing.expectEqual;

pub fn main() void {
    print("\nDay 2: Corruption Checksum\n", .{});
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const data = utils.readFile(allocator, "input/02/input");
    defer allocator.free(data);
    var lines = utils.listFromLines(allocator, data);
    defer lines.deinit();
    var rows = parseRows(allocator, lines.items);
    defer rows.deinit();

    // Part 1
    print("Part 1: {}\n", .{Row.checksum(rows.items)});
}

fn parseRows(allocator: std.mem.Allocator, lines: [][]const u8) std.array_list.Managed(Row) {
    var list = std.array_list.Managed(Row).init(allocator);
    for (lines) |l| {
        var nums = utils.parseToNums(allocator, l, '\t');
        defer nums.deinit();
        list.append(Row.init(nums.items)) catch {
            std.debug.panic("Error appending", .{});
        };
    }
    return list;
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
    /// Calculates the checksum of the spreadsheet (list of rows)
    fn checksum(rows: []const Row) u32 {
        var sum: u32 = 0;
        for (rows) |row| {
            sum += row.difference();
        }
        return sum;
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
    const rows = &[_]Row{
        Row.init(&[_]u32{ 5, 1, 9, 5 }),
        Row.init(&[_]u32{ 7, 5, 3 }),
        Row.init(&[_]u32{ 2, 4, 6, 8 }),
    };
    try expectEqual(18, Row.checksum(rows));
}
