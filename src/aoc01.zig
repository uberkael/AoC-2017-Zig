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
    print("Part 1: {d}\n", .{captchaSum(input)});

    // Part 2
    print("Part 2: {d}\n", .{captchaSumHalfway(input)});
}

// Part 1
/// Sum all digits that match the next digit in the list
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

// 91212129 produces 9 because the only digit that matches the next one is the
// last digit, 9.
test "91212129 produces 9" {
    const input = "91212129";
    const expected_sum = 9;
    const actual_sum = captchaSum(input);
    try std.testing.expectEqual(expected_sum, actual_sum);
}

// Part 2
// 1212 produces 6: the list contains 4 items, and all four digits match the
// digit 2 items ahead.
test "1212 produces 6" {
    const input = "1212";
    const expected_sum = 6;
    const actual_sum = captchaSumHalfway(input);
    try std.testing.expectEqual(expected_sum, actual_sum);
}
// 1221 produces 0, because every comparison is between a 1 and a 2.
test "1221 produces 0" {
    const input = "1221";
    const expected_sum = 0;
    const actual_sum = captchaSumHalfway(input);
    try std.testing.expectEqual(expected_sum, actual_sum);
}
// 123425 produces 4, because both 2s match each other, but no other digit has a
// match.
test "123425 produces 4" {
    const input = "123425";
    const expected_sum = 4;
    const actual_sum = captchaSumHalfway(input);
    try std.testing.expectEqual(expected_sum, actual_sum);
}
// 123123 produces 12.
test "123123 produces 12" {
    const input = "123123";
    const expected_sum = 12;
    const actual_sum = captchaSumHalfway(input);
    try std.testing.expectEqual(expected_sum, actual_sum);
}
// 12131415 produces 4.
test "12131415 produces 4" {
    const input = "12131415";
    const expected_sum = 4;
    const actual_sum = captchaSumHalfway(input);
    try std.testing.expectEqual(expected_sum, actual_sum);
}

////////////
// Part 2 //
////////////
/// Sum all digits that match the digit halfway around the circular list
fn captchaSumHalfway(input: []const u8) u32 {
    var sum: u32 = 0;
    const len = input.len;
    // Check consecutive pairs
    for (input, 0..) |c, i| {
        const next_index = (i + len / 2) % len;
        if (c == input[next_index]) {
            sum += c - '0';
        }
    }
    return sum;
}

// 1122 produces a sum of 3 (1 + 2) because the first digit (1) matches the
// second digit and the third digit (2) matches the fourth digit
test "1122 produces 3" {
    const input = "1122";
    const expected_sum = 3;
    const actual_sum = captchaSum(input);
    try std.testing.expectEqual(expected_sum, actual_sum);
}
