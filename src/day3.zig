const Utils = @import("aoc2025").Utils;
const std = @import("std");

pub fn part1(utils: *Utils) !void {
    try solve(utils, 2);
}

pub fn part2(utils: *Utils) !void {
    try solve(utils, 12);
}

fn solve(utils: *Utils, limit: usize) !void {
    const initialMultiplier = try std.math.powi(u64, 10, limit - 1);
    var result: u64 = 0;

    while (!utils.inputEnded) {
        const line = try utils.readInputLine();
        if (line.len < limit) {
            continue;
        }

        var joltage: u64 = 0;
        var multiplier = initialMultiplier;
        var minIndex: ?usize = null;
        for (0..limit) |i| {
            const distanceFromEnd = limit - 1 - i;
            if (minIndex) |minI| {
                minIndex = minI + 1 + std.mem.indexOfMax(u8, line[minI + 1 .. line.len - distanceFromEnd]);
            } else {
                minIndex = std.mem.indexOfMax(u8, line[0 .. line.len - distanceFromEnd]);
            }
            joltage += multiplier * try std.fmt.charToDigit(line[minIndex.?], 10);
            multiplier /= 10;
        }
        result += joltage;
    }

    try utils.print("{d}", .{result});
}
