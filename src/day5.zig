const Utils = @import("aoc2025").Utils;
const std = @import("std");

const Range = struct {
    min: u64,
    max: u64,
};

fn rangeLess(_: void, a: Range, b: Range) bool {
    if (a.min < b.min) {
        return true;
    } else if (b.min < a.min) {
        return false;
    } else {
        return a.max < b.max;
    }
}

pub fn part1(utils: *Utils) !void {
    const ranges = try parseRanges(utils);
    defer utils.alloc.free(ranges);

    var count: u64 = 0;
    while (!utils.inputEnded) {
        const line = try utils.readInputLine();
        defer utils.alloc.free(line);
        if (line.len == 0) {
            continue;
        }

        const value = try Utils.parseInt(u64, line);
        for (ranges) |range| {
            if (value >= range.min and value <= range.max) {
                count += 1;
                break;
            }
        }
    }

    try utils.print("{d}", .{count});
}

pub fn part2(utils: *Utils) !void {
    const ranges = try parseRanges(utils);
    defer utils.alloc.free(ranges);
    std.mem.sort(Range, ranges, {}, rangeLess);

    var prevMin: u64 = 0;
    var count: u64 = 0;
    for (ranges) |range| {
        const min = @max(prevMin, range.min);
        if (min > range.max) {
            continue;
        }
        count += range.max - min + 1;
        prevMin = range.max + 1;
    }

    try utils.print("{d}", .{count});
}

fn parseRanges(utils: *Utils) ![]Range {
    var ranges = std.ArrayList(Range).empty;
    defer ranges.deinit(utils.alloc);

    while (!utils.inputEnded) {
        const line = try utils.readInputLine();
        defer utils.alloc.free(line);
        if (line.len == 0) {
            break;
        }

        if (std.mem.indexOfScalar(u8, line, '-')) |dashIndex| {
            const min = try Utils.parseInt(u64, line[0..dashIndex]);
            const max = try Utils.parseInt(u64, line[dashIndex + 1 ..]);
            try ranges.append(utils.alloc, .{ .min = min, .max = max });
        }
    }

    return try ranges.toOwnedSlice(utils.alloc);
}
