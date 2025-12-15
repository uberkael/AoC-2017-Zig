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
pub fn getLinesList(
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
pub fn getLinesSlice(
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
    var lines = linesIterator(input);
    return lines.next() orelse "";
}
