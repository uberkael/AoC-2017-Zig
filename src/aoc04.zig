const std = @import("std");
const utils = @import("utils.zig");
const print = std.debug.print;
const expectEqual = std.testing.expectEqual;
const TokenIterator = std.mem.TokenIterator;

pub fn main() void {
    print("\nDay 4: High-Entropy Passphrases\n", .{});
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n", .{});

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const data = utils.readFile(allocator, "input/04/input");
    defer allocator.free(data);
    var lines = std.mem.tokenizeScalar(u8, data, '\n');

    // Part 1
    print("Part 1: {}\n", .{checkPassphrases(allocator, &lines)});
}

fn checkPassphrases(
    allocator: std.mem.Allocator,
    lines: *std.mem.TokenIterator(u8, .scalar),
) u32 {
    var sum: u32 = 0;
    while (lines.next()) |line| {
        if (validWords(allocator, line)) {
            sum += 1;
        }
    }
    return sum;
}

fn validWords(allocator: std.mem.Allocator, line: []const u8) bool {
    var set = std.BufSet.init(allocator);
    defer set.deinit();
    const words = utils.parseToWords(allocator, line);
    defer allocator.free(words);
    for (words) |word| {
        if (set.contains(word)) {
            return false; // duplicate
        }
        set.insert(word) catch {
            return false; // error
        };
    }
    return true; // no duplicates
}

test "aa bb cc dd ee is valid" {
    const allocator = std.testing.allocator;

    const line = "aa bb cc dd ee";
    const result = validWords(allocator, line);
    try expectEqual(true, result);
}
// aa bb cc dd aa is not valid - the word aa appears more than once.
test "aa bb cc dd aa is not valid" {
    const allocator = std.testing.allocator;

    const line = "aa bb cc dd aa";
    const result = validWords(allocator, line);
    try expectEqual(false, result);
}
// aa bb cc dd aaa is valid - aa and aaa count as different words.
test "aa bb cc dd aaa is valid" {
    const allocator = std.testing.allocator;

    const line = "aa bb cc dd aaa";
    const result = validWords(allocator, line);
    try expectEqual(true, result);
}
