const Utils = @import("aoc2025").Utils;
const std = @import("std");

pub fn part1(utils: *Utils) !void {
    var hashtagCounts = [_]u64{0} ** 6;
    for (0..6) |i| {
        while (true) {
            const line = try utils.readInputLine();
            defer utils.alloc.free(line);
            if (line.len == 0) {
                break;
            }
            hashtagCounts[i] += std.mem.count(u8, line, "#");
        }
    }

    var result: u64 = 0;

    while (!utils.inputEnded) {
        const line = try utils.readInputLine();
        defer utils.alloc.free(line);
        if (line.len == 0) {
            continue;
        }
        var parts = std.mem.splitScalar(u8, line, ' ');
        const sizeStrWithColon = parts.next().?;
        const sizeStr = sizeStrWithColon[0 .. sizeStrWithColon.len - 1];
        var sizeSplit = std.mem.splitScalar(u8, sizeStr, 'x');
        const width = try Utils.parseInt(u64, sizeSplit.next().?);
        const height = try Utils.parseInt(u64, sizeSplit.next().?);

        var totalBoxes: u64 = 0;
        var totalArea: u64 = 0;
        for (0..6) |i| {
            const count = try Utils.parseInt(u64, parts.next().?);
            totalBoxes += count;
            totalArea += hashtagCounts[i] * count;
        }

        if (totalArea > width * height) {
            continue;
        } else if (totalBoxes <= (width / 3 * 3) * (height / 3 * 3)) {
            result += 1;
        } else {
            std.debug.print("Oops!\n", .{});
        }
    }

    try utils.print("{d}", .{result});
}
