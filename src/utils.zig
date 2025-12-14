const std = @import("std");

pub fn readFile(allocator: std.mem.Allocator, path: []const u8) []u8 {
    var file = std.fs.cwd().openFile(path, .{}) catch {
        std.debug.panic("file not found: {s}\n", .{path});
    };
    defer file.close();
    return file.readToEndAlloc(allocator, 204800) catch {
        std.debug.panic("Error reading: {s}\n", .{path});
    };
}

pub fn linesIterator(data: []u8) std.mem.TokenIterator(u8, .scalar) {
    return std.mem.tokenizeScalar(u8, data, '\n');
}

pub fn cleanInput(input: []u8) []const u8 {
    var lines = linesIterator(input);
    return lines.next() orelse "";
}
