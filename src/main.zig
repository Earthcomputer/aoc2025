const day1 = @import("day1.zig");
const day2 = @import("day2.zig");
const day3 = @import("day3.zig");
const day4 = @import("day4.zig");
const std = @import("std");
const Utils = @import("aoc2025").Utils;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const inputFile = try std.fs.cwd().openFile("input.txt", .{});
    defer inputFile.close();

    var utils: Utils = .{
        .alloc = allocator,
        .buffer = undefined,
        .inputReader = undefined,
        .inputEnded = false,
    };
    var inputReader = inputFile.reader(&utils.buffer);
    utils.inputReader = &inputReader.interface;

    try utils.print("Which day?", .{});
    const dayStr = try utils.readStdinLine();
    defer utils.alloc.free(dayStr);
    const day = try Utils.parseInt(u8, dayStr);

    try utils.print("Which part?", .{});
    const partStr = try utils.readStdinLine();
    defer utils.alloc.free(partStr);
    const part = try Utils.parseInt(u8, partStr);

    switch (day) {
        1 => {
            if (part == 1) {
                try day1.part1(&utils);
            } else {
                try day1.part2(&utils);
            }
        },
        2 => {
            if (part == 1) {
                try day2.part1(&utils);
            } else {
                try day2.part2(&utils);
            }
        },
        3 => {
            if (part == 1) {
                try day3.part1(&utils);
            } else {
                try day3.part2(&utils);
            }
        },
        4 => {
            if (part == 1) {
                try day4.part1(&utils);
            } else {
                try day4.part2(&utils);
            }
        },
        else => {
            try utils.print("Invalid day", .{});
        },
    }
}
