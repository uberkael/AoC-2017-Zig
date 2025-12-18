const std = @import("std");
const AoC_2017_Zig = @import("AoC_2017_Zig");

const aoc01 = @import("aoc01.zig");
const aoc02 = @import("aoc02.zig");
const aoc03 = @import("aoc03.zig");
const aoc04 = @import("aoc04.zig");

pub fn main() !void {
    try aoc01.main();
    aoc02.main();
    aoc03.main();
    aoc04.main();

    try AoC_2017_Zig.bufferedPrint();
}
