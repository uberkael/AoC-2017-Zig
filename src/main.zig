const std = @import("std");
const AoC_2017_Zig = @import("AoC_2017_Zig");

const aoc01 = @import("aoc01.zig");
const aoc02 = @import("aoc02.zig");

pub fn main() !void {
    try aoc01.main();
    aoc02.main();

    try AoC_2017_Zig.bufferedPrint();
}
