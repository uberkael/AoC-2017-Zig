const std = @import("std");
const utils = @import("utils.zig");
const print = std.debug.print;
const expectEqual = std.testing.expectEqual;
const TokenIterator = std.mem.TokenIterator;

pub fn main() void {
    print("\nDay 4: High-Entropy Passphrases\n", .{});
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n", .{});

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const data = utils.readFile(allocator, "input/04/input");
    defer allocator.free(data);

    // Part 1
    print("Part 1: {}\n", .{checkPassphrases(allocator, data, validWords)});

    // Part 2
    print("Part 2: {}\n", .{checkPassphrases(allocator, data, NoAnagrams)});
}

/// Count valid passphrases in input data
fn checkPassphrases(
    allocator: std.mem.Allocator,
    data: []const u8,
    sumFunc: fn (std.mem.Allocator, []const u8) bool,
) u32 {
    var sum: u32 = 0;
    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        if (sumFunc(allocator, line)) {
            sum += 1;
        }
    }
    return sum;
}

/// Check if a passphrase has no duplicates
fn validWords(allocator: std.mem.Allocator, line: []const u8) bool {
    var set = std.BufSet.init(allocator);
    defer set.deinit();
    var words = std.mem.tokenizeScalar(u8, line, ' ');
    while (words.next()) |word| {
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

////////////
// Part 2 //
////////////
/// Check if a passphrase has no anagram duplicates
fn NoAnagrams(allocator: std.mem.Allocator, line: []const u8) bool {
    var map = std.AutoHashMap([26]u8, void).init(allocator);
    defer map.deinit();
    var words = std.mem.tokenizeScalar(u8, line, ' ');
    while (words.next()) |word| {
        var freq = [_]u8{0} ** 26;
        for (word) |c| {
            freq[c - 'a'] += 1;
        }
        if (map.contains(freq)) {
            return false; // anagram duplicate
        }
        map.put(freq, {}) catch {
            return false; // error
        };
    }
    return true; // no anagram duplicates
}

// abcde fghij is a valid passphrase.
test "abcde fghij is valid" {
    const allocator = std.testing.allocator;

    const line = "abcde fghij";
    const result = NoAnagrams(allocator, line);
    try expectEqual(true, result);
}
// abcde xyz ecdab is not valid - the letters from the third word can be rearranged to form the first word.
test "abcde xyz ecdab is not valid" {
    const allocator = std.testing.allocator;

    const line = "abcde xyz ecdab";
    const result = NoAnagrams(allocator, line);
    try expectEqual(false, result);
}
// a ab abc abd abf abj is a valid passphrase, because all letters need to be used when forming another word.
test "a ab abc abd abf abj is valid" {
    const allocator = std.testing.allocator;

    const line = "a ab abc abd abf abj";
    const result = NoAnagrams(allocator, line);
    try expectEqual(true, result);
}
// iiii oiii ooii oooi oooo is valid.
test "iiii oiii ooii oooi oooo is valid" {
    const allocator = std.testing.allocator;

    const line = "iiii oiii ooii oooi oooo";
    const result = NoAnagrams(allocator, line);
    try expectEqual(true, result);
}
// oiii ioii iioi iiio is not valid - any of these words can be rearranged to form any other word.
test "oiii ioii iioi iiio is not valid" {
    const allocator = std.testing.allocator;

    const line = "oiii ioii iioi iiio";
    const result = NoAnagrams(allocator, line);
    try expectEqual(false, result);
}
