const std = @import("std");
const utils = @import("utils.zig");
const print = std.debug.print;
const expectEqual = std.testing.expectEqual;
const TokenIterator = std.mem.TokenIterator;

pub fn main() void {
    print("\nDay 6: Memory Reallocation\n", .{});
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━\n", .{});

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const data = utils.readFile(allocator, "input/06/input");
    defer allocator.free(data);

    // Part 1
    var memory: [16]i32 = readMemory(16, data);
    const steps = cycles(16, &memory);
    print("Part 1: {}\n", .{steps});

    // Part 1
    memory = readMemory(16, data);
    const loop_size = loops(16, &memory);
    print("Part 2: {}\n", .{loop_size});
}

/// Read data to a N sized array of i32
fn readMemory(
    comptime N: usize,
    data: []const u8,
) [N]i32 {
    var memory: [N]i32 = undefined;
    var iter = std.mem.tokenizeScalar(u8, data, '\t');
    var i: usize = 0;
    while (iter.next()) |token| : (i += 1) {
        if (i >= N) break;
        const trimmed = std.mem.trim(u8, token, &std.ascii.whitespace);
        memory[i] = std.fmt.parseInt(i32, trimmed, 10) catch 0;
    }
    return memory;
}

/// Cycles until a configuration is repeated, returns steps
fn cycles(comptime N: usize, memory: *[N]i32) u32 {
    var seen = std.AutoHashMap([N]i32, u32).init(std.heap.page_allocator);
    defer seen.deinit();
    var steps: u32 = 0;
    while (true) {
        const key: [N]i32 = memory.*;
        if (seen.get(key)) |_| {
            break;
        } else {
            seen.put(key, steps) catch |err| {
                std.debug.panic("Error inserting into hashmap: {}", .{err});
            };
        }
        cycle(N, memory);
        steps += 1;
    }
    return steps;
}

/// Redistribution cycle on the memory banks
fn cycle(comptime N: usize, memory: *[N]i32) void {
    var idx = std.mem.indexOfMax(i32, memory);
    var value = memory[idx];
    // Reset the Bank
    memory[idx] = 0;
    // Redistribution
    while (value > 0) : (value -= 1) {
        idx = (idx + 1) % N;
        memory[idx] += 1;
    }
}

test "cycle test" {
    var memory = [4]i32{ 0, 2, 7, 0 };

    cycle(4, &memory);
    try expectEqual([4]i32{ 2, 4, 1, 2 }, memory);

    cycle(4, &memory);
    try expectEqual([4]i32{ 3, 1, 2, 3 }, memory);

    cycle(4, &memory);
    try expectEqual([4]i32{ 0, 2, 3, 4 }, memory);

    cycle(4, &memory);
    try expectEqual([4]i32{ 1, 3, 4, 1 }, memory);
}

test "cycles test" {
    var memory = [4]i32{ 0, 2, 7, 0 };
    const steps = cycles(4, &memory);

    try expectEqual([4]i32{ 2, 4, 1, 2 }, memory);
    try expectEqual(5, steps);
}

////////////
// Part 2 //
////////////
/// Cycles until a configuration is repeated, returns the loop size
fn loops(comptime N: usize, memory: *[N]i32) u32 {
    var seen = std.AutoHashMap([N]i32, u32).init(std.heap.page_allocator);
    defer seen.deinit();
    var steps: u32 = 0;
    // Steps at first occurrence
    var previous: u32 = 0;
    while (true) {
        const key: [N]i32 = memory.*;
        if (seen.get(key)) |p| {
            previous = p;
            break;
        } else {
            seen.put(key, steps) catch |err| {
                std.debug.panic("Error inserting into hashmap: {}", .{err});
            };
        }
        cycle(N, memory);
        steps += 1;
    }
    // Loop size = final steps - fist occurrence steps
    return steps - previous;
}

test "loops test" {
    var memory = [4]i32{ 2, 4, 1, 2 };
    const loop_size = loops(4, &memory);

    try expectEqual([4]i32{ 2, 4, 1, 2 }, memory);
    try expectEqual(4, loop_size);
}
