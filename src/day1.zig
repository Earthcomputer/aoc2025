const Utils = @import("aoc2025").Utils;
const std = @import("std");

pub fn part1(utils: *Utils) !void {
    var result: i32 = 50;
    var count: usize = 0;
    while (!utils.inputEnded) {
        const line = try utils.readInputLine();
        defer utils.alloc.free(line);

        if (std.mem.startsWith(u8, line, "L")) {
            const amt = try Utils.parseInt(i32, line[1..]);
            result -= amt;
            result = @mod(result, 100);
        } else if (std.mem.startsWith(u8, line, "R")) {
            const amt = try Utils.parseInt(i32, line[1..]);
            result += amt;
            result = @mod(result, 100);
        }

        if (result == 0) {
            count += 1;
        }
    }

    try utils.print("{d}", .{count});
}

pub fn part2(utils: *Utils) !void {
    var result: i32 = 50;
    var count: i32 = 0;
    while (!utils.inputEnded) {
        const line = try utils.readInputLine();
        defer utils.alloc.free(line);

        if (std.mem.startsWith(u8, line, "L")) {
            const amt = try Utils.parseInt(i32, line[1..]);
            if (result == 0) {
                // we will end up double counting one, so subtract one in advance
                count -= 1;
            }
            result -= amt;
            if (result <= 0) {
                count -= @divFloor(result - 1, 100);
                result = @mod(result, 100);
            }
        } else if (std.mem.startsWith(u8, line, "R")) {
            const amt = try Utils.parseInt(i32, line[1..]);
            result += amt;
            count += @divFloor(result, 100);
            result = @mod(result, 100);
        }
    }

    try utils.print("{d}", .{count});
}
