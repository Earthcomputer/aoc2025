const Utils = @import("aoc2025").Utils;
const std = @import("std");

pub fn part1(utils: *Utils) !void {
    try solve(utils, isValid1);
}

fn isValid1(str: []const u8) bool {
    if (str.len % 2 != 0) {
        return false;
    }

    const halfLen = str.len / 2;
    return std.mem.eql(u8, str[0..halfLen], str[halfLen..]);
}

pub fn part2(utils: *Utils) !void {
    try solve(utils, isValid2);
}

fn isValid2(str: []const u8) bool {
    if (str.len < 2) {
        return false;
    }

    for (2..str.len + 1) |partCount| {
        if (str.len % partCount != 0) {
            continue;
        }

        const partLen = str.len / partCount;
        for (1..partCount) |i| {
            if (!std.mem.eql(u8, str[0..partLen], str[i * partLen .. (i + 1) * partLen])) {
                break;
            }
        } else {
            return true;
        }
    }

    return false;
}

fn solve(utils: *Utils, comptime isValid: fn (str: []const u8) bool) !void {
    const inputLine = try utils.readInputLine();
    defer utils.alloc.free(inputLine);
    var toStringBuffer = std.io.Writer.Allocating.init(utils.alloc);
    defer toStringBuffer.deinit();

    var result: u64 = 0;

    var ranges = std.mem.splitScalar(u8, inputLine, ',');
    while (ranges.next()) |range| {
        var rangeSplit = std.mem.splitScalar(u8, range, '-');
        const first = rangeSplit.next();
        const second = rangeSplit.next();
        if (first == null or second == null) {
            continue;
        }
        const start = try Utils.parseInt(u64, first.?);
        const end = try Utils.parseInt(u64, second.?);
        for (start..end + 1) |i| {
            toStringBuffer.clearRetainingCapacity();
            try toStringBuffer.writer.print("{d}", .{i});
            if (isValid(toStringBuffer.written())) {
                result += i;
            }
        }
    }

    try utils.print("{d}", .{result});
}
