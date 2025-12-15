const std = @import("std");

/// Reads the entire content of a file into a byte slice
pub fn readFile(allocator: std.mem.Allocator, path: []const u8) []u8 {
    var file = std.fs.cwd().openFile(path, .{}) catch {
        std.debug.panic("file not found: {s}\n", .{path});
    };
    defer file.close();
    return file.readToEndAlloc(allocator, 204800) catch {
        std.debug.panic("Error reading: {s}\n", .{path});
    };
}

/// Returns an iterator that yields lines from the given data
pub fn linesIterator(data: []const u8) std.mem.TokenIterator(u8, .scalar) {
    return std.mem.tokenizeScalar(u8, data, '\n');
}

/// Returns an ArrayList containing all the lines as byte slices
pub fn listFromLines(
    allocator: std.mem.Allocator,
    data: []const u8,
) std.array_list.Managed([]const u8) {
    var lines = std.array_list.Managed([]const u8).init(allocator);
    lines.ensureTotalCapacity(16) catch |err| {
        std.debug.panic("Error allocating capacity: {}", .{err});
    };
    var iter = linesIterator(data);
    while (iter.next()) |line| {
        lines.append(line) catch |err| {
            std.debug.panic("Error appending line: {}", .{err});
        };
    }
    return lines;
}

/// Returns a slice of slices containing all the lines
pub fn sliceFromLines(
    allocator: std.mem.Allocator,
    data: []const u8,
) [][]const u8 {
    var lines = std.array_list.Managed([]const u8).init(allocator);
    defer lines.deinit();
    var iter = linesIterator(data);
    while (iter.next()) |line| {
        lines.append(line) catch |err| {
            std.debug.panic("Error appending line: {}", .{err});
        };
    }
    return lines.toOwnedSlice() catch |err| {
        std.debug.panic("Error converting to owned slice: {}", .{err});
    };
}

/// Removes trailing newlines from the input
pub fn cleanInput(input: []const u8) []const u8 {
    if (input.len > 0 and input[input.len - 1] == '\n') {
        return input[0 .. input.len - 1];
    }
    return input;
}

/// Parse a slice separated by char into u32 array
pub fn parseToNums(
    allocator: std.mem.Allocator,
    line: []const u8,
    char: u8,
) std.array_list.Managed(u32) {
    var list = std.array_list.Managed(u32).init(allocator);
    var parse_iter = std.mem.tokenizeScalar(u8, line, char);
    while (parse_iter.next()) |num_str| {
        const num = std.fmt.parseInt(u32, num_str, 10) catch |err| {
            std.debug.panic("Error parsing number: {}", .{err});
        };
        list.append(num) catch |err| {
            std.debug.panic("Error appending number: {}", .{err});
        };
    }
    return list;
}

///////////
// Tests //
///////////
test "readFile" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const file_path = "input/01/input";
    const read_content = readFile(allocator, file_path);
    defer allocator.free(read_content);

    try std.testing.expect(read_content.len > 0);
}

test "linesIterator" {
    const data = "line1\nline2\nline3";
    var iter = linesIterator(data);

    try std.testing.expectEqualStrings("line1", iter.next().?);
    try std.testing.expectEqualStrings("line2", iter.next().?);
    try std.testing.expectEqualStrings("line3", iter.next().?);
    try std.testing.expect(iter.next() == null);
}

test "listFromLines" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const data = "line1\nline2\nline3";
    var lines = listFromLines(allocator, data);
    defer lines.deinit();

    try std.testing.expectEqual(3, lines.items.len);
    try std.testing.expectEqualStrings("line1", lines.items[0]);
    try std.testing.expectEqualStrings("line2", lines.items[1]);
    try std.testing.expectEqualStrings("line3", lines.items[2]);
}

test "sliceFromLines" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const data = "line1\nline2\nline3";
    const lines = sliceFromLines(allocator, data);
    defer allocator.free(lines);

    try std.testing.expectEqual(3, lines.len);
    try std.testing.expectEqualStrings("line1", lines[0]);
    try std.testing.expectEqualStrings("line2", lines[1]);
    try std.testing.expectEqualStrings("line3", lines[2]);
}

test "cleanInput" {
    const input = "hello world\n";
    const cleaned = cleanInput(input);
    try std.testing.expectEqualStrings("hello world", cleaned);

    const input2 = "no newline";
    const cleaned2 = cleanInput(input2);
    try std.testing.expectEqualStrings("no newline", cleaned2);

    const input3 = "\n";
    const cleaned3 = cleanInput(input3);
    try std.testing.expectEqualStrings("", cleaned3);
}

test "parseToNums" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const line = "1,2,3,4";
    var nums = parseToNums(allocator, line, ',');
    defer nums.deinit();

    try std.testing.expectEqual(4, nums.items.len);
    try std.testing.expectEqual(1, nums.items[0]);
    try std.testing.expectEqual(2, nums.items[1]);
    try std.testing.expectEqual(3, nums.items[2]);
    try std.testing.expectEqual(4, nums.items[3]);
}
