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

    // Part 2
    const larger_value = findFirstLargerValue(allocator, input) catch |err| {
        std.debug.panic("Error finding larger value: {}", .{err});
    };
    print("Part 2: {d}\n", .{larger_value});
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

////////////
// Part 2 //
////////////
/// Grid position
const Point = struct {
    x: i32,
    y: i32,
};

/// Spiral Value Generator
/// The cell is the sum of its neighboring cells
const SpiralGenerator = struct {
    grid: std.AutoHashMap(Point, u32),
    x: i32,
    y: i32,
    num: u32,
    size: u32,
    started: bool,
    step_index: usize,
    allocator: std.mem.Allocator,

    // Directions for the 8 neighbors of a cell
    const directions = [_]Point{
        .{ .x = -1, .y = -1 },
        .{ .x = -1, .y = 0 },
        .{ .x = -1, .y = 1 },
        .{ .x = 0, .y = -1 },
        .{ .x = 0, .y = 1 },
        .{ .x = 1, .y = -1 },
        .{ .x = 1, .y = 0 },
        .{ .x = 1, .y = 1 },
    };

    // Steps for moving in the spiral: right, up, left, down
    const steps = [_]Point{
        .{ .x = 1, .y = 0 }, // right
        .{ .x = 0, .y = 1 }, // up
        .{ .x = -1, .y = 0 }, // left
        .{ .x = 0, .y = -1 }, // down
    };

    pub fn init(allocator: std.mem.Allocator) !SpiralGenerator {
        var grid = std.AutoHashMap(Point, u32).init(allocator);
        // Start with the center cell = 1
        try grid.put(.{ .x = 0, .y = 0 }, 1);

        return SpiralGenerator{
            .grid = grid,
            // start position (1,0)
            .x = 1,
            .y = 0,
            .num = 2,
            .size = 3,
            .started = false,
            // Index for cycling through steps (start going up)
            .step_index = 1,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *SpiralGenerator) void {
        self.grid.deinit();
    }

    /// Calculate the next value in the spiral
    pub fn next(self: *SpiralGenerator) !?u32 {
        // Start with the center value = 1
        if (!self.started) {
            self.started = true;
            return 1;
        }
        // Sum of neighboring cells
        var value: u32 = 0;
        for (directions) |dir| {
            const neighbor = Point{ .x = self.x + dir.x, .y = self.y + dir.y };
            if (self.grid.get(neighbor)) |v| {
                value += v;
            }
        }

        // Save the value in the grid
        try self.grid.put(.{ .x = self.x, .y = self.y }, value);

        // Determine next position
        if (self.num == self.size * self.size) {
            // Next ring of the spiral
            self.size += 2;
            self.x += 1;
            self.step_index = (self.step_index + 1) % steps.len;
        } else {
            // Check if we are at a corner
            const prev_size = self.size - 2;
            if ((self.num - (prev_size * prev_size)) % (self.size - 1) == 0) {
                self.step_index = (self.step_index + 1) % steps.len;
            }
            // Move in the current direction
            const step = steps[self.step_index];
            self.x += step.x;
            self.y += step.y;
        }

        self.num += 1;
        return value;
    }
};

/// Finds the first value larger than the input value in the spiral
fn findFirstLargerValue(allocator: std.mem.Allocator, target: u32) !u32 {
    var generator = try SpiralGenerator.init(allocator);
    defer generator.deinit();

    // First value is always 1
    if (1 > target) return 1;

    // Generate values until finding one larger than target
    while (try generator.next()) |value| {
        if (value > target) {
            return value;
        }
    }

    return error.NotFound;
}

test "spiral generator first values" {
    var generator = try SpiralGenerator.init(std.testing.allocator);
    defer generator.deinit();

    // First values expected from the spiral (including the initial 1)
    const expected = [_]u32{ 1, 1, 2, 4, 5, 10, 11, 23, 25, 26, 54, 57, 59, 122, 133, 142, 147, 304, 330, 351, 362, 747, 806 };

    // First value is 1
    var idx: usize = 0;
    while (idx < expected.len) : (idx += 1) {
        const value = (try generator.next()).?;
        try expectEqual(expected[idx], value);
    }
}
