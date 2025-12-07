const Utils = @import("aoc2025").Utils;
const std = @import("std");

pub fn part1(utils: *Utils) !void {
    var beamIndexes = std.ArrayList(usize).empty;
    defer beamIndexes.deinit(utils.alloc);
    var nextBeamIndexes = std.ArrayList(usize).empty;
    defer nextBeamIndexes.deinit(utils.alloc);

    {
        const line = try utils.readInputLine();
        defer utils.alloc.free(line);
        const startIndex = std.mem.indexOfScalar(u8, line, 'S').?;
        try beamIndexes.append(utils.alloc, startIndex);
    }

    var splitCount: u64 = 0;

    while (!utils.inputEnded) {
        const line = try utils.readInputLine();
        defer utils.alloc.free(line);

        for (beamIndexes.items) |beamIndex| {
            if (beamIndex < line.len and line[beamIndex] == '^') {
                if (beamIndex != 0 and nextBeamIndexes.getLastOrNull() != beamIndex - 1) {
                    try nextBeamIndexes.append(utils.alloc, beamIndex - 1);
                }
                try nextBeamIndexes.append(utils.alloc, beamIndex + 1);
                splitCount += 1;
            } else {
                if (nextBeamIndexes.getLastOrNull() != beamIndex) {
                    try nextBeamIndexes.append(utils.alloc, beamIndex);
                }
            }
        }

        std.mem.swap(std.ArrayList(usize), &beamIndexes, &nextBeamIndexes);
        nextBeamIndexes.clearRetainingCapacity();
    }

    try utils.print("{d}", .{splitCount});
}

pub fn part2(utils: *Utils) !void {
    var beamCounts = blk: {
        const line = try utils.readInputLine();
        defer utils.alloc.free(line);
        const startIndex = std.mem.indexOfScalar(u8, line, 'S').?;
        var indexes = try utils.alloc.alloc(u64, line.len);
        @memset(indexes, 0);
        indexes[startIndex] = 1;
        break :blk indexes;
    };
    defer utils.alloc.free(beamCounts);
    var nextBeamCounts = try utils.alloc.alloc(u64, beamCounts.len);
    @memset(nextBeamCounts, 0);
    defer utils.alloc.free(nextBeamCounts);

    while (!utils.inputEnded) {
        const line = try utils.readInputLine();
        defer utils.alloc.free(line);

        for (0..beamCounts.len) |i| {
            if (i < line.len and line[i] == '^') {
                if (i != 0) {
                    nextBeamCounts[i - 1] += beamCounts[i];
                }
                if (i + 1 < nextBeamCounts.len) {
                    nextBeamCounts[i + 1] += beamCounts[i];
                }
            } else {
                nextBeamCounts[i] += beamCounts[i];
            }
        }

        std.mem.swap([]u64, &beamCounts, &nextBeamCounts);
        @memset(nextBeamCounts, 0);
    }

    var sum: u64 = 0;
    for (beamCounts) |count| {
        sum += count;
    }

    try utils.print("{d}", .{sum});
}
