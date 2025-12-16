const std = @import("std");
const utils = @import("utils.zig");
const print = std.debug.print;
const expectEqual = std.testing.expectEqual;
const TokenIterator = std.mem.TokenIterator;

pub fn main() void {
    print("\nDay 3: Spiral Memory\n", .{});
    print("━━━━━━━━━━━━━━━━━━━━\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const data = utils.readFile(allocator, "input/03/input");
    defer allocator.free(data);
    const input_str = utils.cleanInput(data);
    const input = std.fmt.parseInt(u32, input_str, 10) catch |err| {
        std.debug.panic("Error parsing number: {}", .{err});
    };

    // Part 1
    print("Part 1: {d}\n", .{distanceToCenter(input)});
}

/// Get the spiral level (ring number) for a given number
/// n <= (2k+1)²
fn spiralLevel(n: u32) u32 {
    if (n == 1) return 0;
    const nf: f64 = @floatFromInt(n);
    const sqrt_n = std.math.sqrt(nf);
    // Next odd integer
    var side = @as(u32, @intFromFloat(@ceil(sqrt_n)));
    if (side % 2 == 0) {
        side += 1;
    }
    // side = 2k+1 => k = (side-1)/2
    const level = (side - 1) / 2;
    return level;
}

/// Get the four cardinal numbers (center of each side)
/// Order: right, up, left, down
fn cardinalNumbers(level: u32) [4]u32 {
    if (level == 0) return [4]u32{ 1, 1, 1, 1 };
    // Level k ends at (2k+1)²
    const side = 2 * level + 1;
    const max_num = side * side;
    // Each side has length 2k
    const side_length = 2 * level;

    const down = max_num - level;
    const left = down - side_length;
    const up = left - side_length;
    const right = up - side_length;

    return [4]u32{ right, up, left, down };
}

/// Compute distance from n to the nearest cardinal of its level
/// Returns: struct { level: u32, distance: u32 }
fn distanceToNearestCardinal(n: u32) struct { level: u32, distance: u32 } {
    const level = spiralLevel(n);
    if (level == 0) return .{ .level = 0, .distance = 0 };

    const cards = cardinalNumbers(level);
    var min: u32 = std.math.maxInt(u32);
    inline for (cards) |c| {
        const d = if (n >= c) n - c else c - n;
        if (d < min) min = d;
    }
    return .{ .level = level, .distance = min };
}

/// Compute distance from n to center (Manhattan):
/// distance = level + distance to nearest cardinal on that ring
fn distanceToCenter(n: u32) u32 {
    const result = distanceToNearestCardinal(n);
    return result.level + result.distance;
}

test "1 spiral level = 0" {
    try expectEqual(0, spiralLevel(1));
}
test "2 spiral level = 1" {
    try expectEqual(1, spiralLevel(2));
}
test "9 spiral level = 1" {
    try expectEqual(1, spiralLevel(9));
}
test "10 spiral level = 2" {
    try expectEqual(2, spiralLevel(10));
}
test "level 1 cardinals" {
    const expected = [4]u32{ 2, 4, 6, 8 };
    try expectEqual(expected, cardinalNumbers(1));
}
test "level 2 cardinals" {
    const expected = [4]u32{ 11, 15, 19, 23 };
    try expectEqual(expected, cardinalNumbers(2));
}

// Data from square 1 is carried 0 steps, since it's at the access port.
test "1 is 0 steps" {
    try expectEqual(0, distanceToCenter(1));
}
// Data from square 12 is carried 3 steps, such as: down, left, left.
test "12 is 3 steps" {
    try expectEqual(3, distanceToCenter(12));
}
// Data from square 23 is carried only 2 steps: up twice.
test "23 is 2 steps" {
    try expectEqual(2, distanceToCenter(23));
}
// Data from square 1024 must be carried 31 steps.
test "1024 is 31 steps" {
    try expectEqual(31, distanceToCenter(1024));
}
