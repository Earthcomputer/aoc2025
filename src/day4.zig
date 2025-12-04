const Utils = @import("aoc2025").Utils;
const std = @import("std");

pub fn part1(utils: *Utils) !void {
    var grid = std.array_list.Managed([]u8).init(utils.alloc);
    defer {
        for (grid.items) |item| {
            utils.alloc.free(item);
        }
        grid.deinit();
    }

    while (!utils.inputEnded) {
        try grid.append(try utils.readInputLine());
    }

    const count = run_iter(grid.items, false);
    try utils.print("{d}", .{count});
}

pub fn part2(utils: *Utils) !void {
    var grid = std.array_list.Managed([]u8).init(utils.alloc);
    defer {
        for (grid.items) |item| {
            utils.alloc.free(item);
        }
        grid.deinit();
    }

    while (!utils.inputEnded) {
        try grid.append(try utils.readInputLine());
    }

    var count: u64 = 0;
    while (true) {
        const delta = run_iter(grid.items, true);
        if (delta == 0) {
            break;
        }
        count += delta;
    }
    try utils.print("{d}", .{count});
}

fn run_iter(grid: [][]u8, modify: bool) u64 {
    var count: u64 = 0;
    for (0..grid.len) |y| {
        for (0..grid[y].len) |x| {
            if (grid[y][x] == '@') {
                var neighborCount: u8 = 0;
                for (0..3) |udy| {
                    const dy = Utils.cast(isize, udy) - 1;
                    for (0..3) |udx| {
                        const dx = Utils.cast(isize, udx) - 1;
                        if ((dx != 0 or dy != 0) and grid_get(grid, Utils.cast(isize, x) + dx, Utils.cast(isize, y) + dy) == '@') {
                            neighborCount += 1;
                        }
                    }
                }

                if (neighborCount < 4) {
                    count += 1;
                    if (modify) {
                        grid[y][x] = '.';
                    }
                }
            }
        }
    }
    return count;
}

fn grid_get(grid: []const []const u8, x: isize, y: isize) ?u8 {
    if (y < 0 or y >= grid.len) {
        return null;
    }
    if (x < 0 or x >= grid[Utils.cast(usize, y)].len) {
        return null;
    }
    return grid[Utils.cast(usize, y)][Utils.cast(usize, x)];
}
