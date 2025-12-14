const std = @import("std");
const utils = @import("utils.zig");
const print = std.debug.print;

pub fn main() !void {
    print("\nDay 1: Inverse Captcha\n", .{});
    print("━━━━━━━━━━━━━━━━━━━━━━\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const data = utils.readFile(allocator, "input/01/input");
    defer allocator.free(data);
    const input = utils.cleanInput(data);

    // Part 1
    const sum = captchaSum(input);
    print("Part 1: {d}\n", .{sum});
}

// Part 1
fn captchaSum(input: []const u8) u32 {
    var sum: u32 = 0;
    const last = input.len;
    // Check consecutive pairs
    for (input, 0..) |c, i| {
        const next_index = (i + 1) % last;
        if (c == input[next_index]) {
            sum += c - '0';
        }
    }
    return sum;
}

// 1122 produces a sum of 3 (1 + 2) because the first digit (1) matches the second digit and the third digit (2) matches the fourth digit
test "1122 produces 3" {
    const input = "1122";
    const expected_sum = 3;
    const actual_sum = captchaSum(input);
    try std.testing.expectEqual(expected_sum, actual_sum);
}

// 1111 produces 4 because each digit (all 1) matches the next.
test "1111 produces 4" {
    const input = "1111";
    const expected_sum = 4;
    const actual_sum = captchaSum(input);
    try std.testing.expectEqual(expected_sum, actual_sum);
}

// 1234 produces 0 because no digit matches the next.
test "1234 produces 0" {
    const input = "1234";
    const expected_sum = 0;
    const actual_sum = captchaSum(input);
    try std.testing.expectEqual(expected_sum, actual_sum);
}

// 91212129 produces 9 because the only digit that matches the next one is the last digit, 9.
test "91212129 produces 9\n" {
    const input = "91212129";
    const expected_sum = 9;
    const actual_sum = captchaSum(input);
    try std.testing.expectEqual(expected_sum, actual_sum);
}
