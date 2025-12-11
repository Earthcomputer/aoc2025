const Utils = @import("aoc2025").Utils;
const std = @import("std");

const Machine = struct {
    targetState: u64,
    maxState: u64,
    buttons: []u64,
    joltage: []u64,

    fn deinit(self: *const Machine, alloc: std.mem.Allocator) void {
        alloc.free(self.buttons);
        alloc.free(self.joltage);
    }
};

pub fn part1(utils: *Utils) !void {
    const machines = try parseMachines(utils);
    defer {
        for (machines) |*machine| {
            machine.deinit(utils.alloc);
        }
        utils.alloc.free(machines);
    }

    var total: u64 = 0;
    for (machines) |machine| {
        var reachable = try utils.alloc.alloc(bool, Utils.cast(usize, machine.maxState));
        defer utils.alloc.free(reachable);
        @memset(reachable, false);
        reachable[0] = true;

        var nextReachable = try utils.alloc.alloc(bool, reachable.len);
        defer utils.alloc.free(nextReachable);

        while (!reachable[machine.targetState]) {
            total += 1;

            @memcpy(nextReachable, reachable);

            for (0..machine.maxState) |state| {
                if (reachable[state]) {
                    for (machine.buttons) |button| {
                        nextReachable[state ^ Utils.cast(usize, button)] = true;
                    }
                }
            }

            std.mem.swap([]bool, &reachable, &nextReachable);
        }
    }

    try utils.print("{d}", .{total});
}

pub fn part2(utils: *Utils) !void {
    const machines = try parseMachines(utils);
    defer {
        for (machines) |*machine| {
            machine.deinit(utils.alloc);
        }
        utils.alloc.free(machines);
    }

    var total: u64 = 0;
    var i: u64 = 0;
    for (machines) |*machine| {
        std.debug.print("Machine {d}!\n", .{i});
        i += 1;
        total += (try part2SolveMachine(utils, machine)).?;
    }

    try utils.print("{d}", .{total});
}

fn part2SolveMachine(utils: *Utils, machine: *const Machine) !?u64 {
    var joltageButtonCount = try utils.alloc.alloc(u64, machine.joltage.len);
    defer utils.alloc.free(joltageButtonCount);
    @memset(joltageButtonCount, 0);

    for (machine.buttons) |button| {
        var buttonRemaining = button;
        while (buttonRemaining != 0) {
            const bit = @ctz(buttonRemaining);
            joltageButtonCount[Utils.cast(usize, bit)] += 1;
            buttonRemaining &= ~(@as(u64, 1) << Utils.cast(u6, bit));
        }
    }

    var minJoltage: usize = std.math.maxInt(usize);
    var minButtonCount: u64 = std.math.maxInt(u64);
    for (0..joltageButtonCount.len) |i| {
        if (joltageButtonCount[i] != 0 and joltageButtonCount[i] < minButtonCount) {
            minJoltage = i;
            minButtonCount = joltageButtonCount[i];
        }
    }

    if (minJoltage == std.math.maxInt(usize)) {
        if (std.mem.allEqual(u64, machine.joltage, 0)) {
            return 0;
        } else {
            return null;
        }
    }

    var foundButton: u64 = undefined;
    const newButtons = try utils.alloc.alloc(u64, machine.buttons.len);
    defer utils.alloc.free(newButtons);
    @memcpy(newButtons, machine.buttons);
    for (newButtons) |*button| {
        if ((button.* & (@as(u64, 1) << Utils.cast(u6, minJoltage))) != 0) {
            foundButton = button.*;
            button.* = 0;
            break;
        }
    } else {
        std.debug.print("Oops!\n", .{});
    }

    const newJoltage = try utils.alloc.alloc(u64, machine.joltage.len);
    defer utils.alloc.free(newJoltage);

    if (minButtonCount == 1) {
        @memcpy(newJoltage, machine.joltage);
        const joltageToReduce = machine.joltage[minJoltage];
        var buttonRemaining = foundButton;
        while (buttonRemaining != 0) {
            const bit = @ctz(buttonRemaining);
            const joltage = Utils.cast(usize, bit);
            if (newJoltage[joltage] < joltageToReduce) {
                return null;
            }
            newJoltage[joltage] -= joltageToReduce;
            buttonRemaining &= ~(@as(u64, 1) << Utils.cast(u6, bit));
        }

        const newMachine: Machine = .{ .targetState = machine.targetState, .maxState = machine.maxState, .buttons = newButtons, .joltage = newJoltage };
        if (try part2SolveMachine(utils, &newMachine)) |result| {
            return result + joltageToReduce;
        } else {
            return null;
        }
    } else {
        var minResult: u64 = std.math.maxInt(u64);
        joltageLoop: for (0..machine.joltage[minJoltage] + 1) |i| {
            @memcpy(newJoltage, machine.joltage);
            const joltageToReduce = Utils.cast(u64, i);
            var buttonRemaining = foundButton;
            while (buttonRemaining != 0) {
                const bit = @ctz(buttonRemaining);
                const joltage = Utils.cast(usize, bit);
                if (newJoltage[joltage] < joltageToReduce) {
                    break :joltageLoop;
                }
                newJoltage[joltage] -= joltageToReduce;
                buttonRemaining &= ~(@as(u64, 1) << Utils.cast(u6, bit));
            }

            const newMachine: Machine = .{ .targetState = machine.targetState, .maxState = machine.maxState, .buttons = newButtons, .joltage = newJoltage };
            if (try part2SolveMachine(utils, &newMachine)) |result| {
                minResult = @min(minResult, result + joltageToReduce);
            }
        }

        if (minResult == std.math.maxInt(u64)) {
            return null;
        }
        return minResult;
    }
}

fn parseMachines(utils: *Utils) ![]Machine {
    var success = false;
    var machines = std.ArrayList(Machine).empty;
    defer {
        if (!success) {
            for (machines.items) |*machine| {
                machine.deinit(utils.alloc);
            }
        }
        machines.deinit(utils.alloc);
    }

    while (!utils.inputEnded) {
        const line = try utils.readInputLine();
        defer utils.alloc.free(line);

        if (line.len == 0) {
            continue;
        }

        var split = std.mem.splitScalar(u8, line, ' ');

        const targetStateStr = split.next().?;
        var mask: u64 = 1;
        var targetState: u64 = 0;
        for (targetStateStr[1 .. targetStateStr.len - 1]) |c| {
            if (c == '#') {
                targetState |= mask;
            }
            mask <<= 1;
        }
        const maxState: u64 = @as(u64, 1) << Utils.cast(u6, (targetStateStr.len - 2));

        var buttons = std.ArrayList(u64).empty;
        defer buttons.deinit(utils.alloc);
        var joltage = std.ArrayList(u64).empty;
        defer joltage.deinit(utils.alloc);

        while (split.next()) |part| {
            if (std.mem.startsWith(u8, part, "(")) {
                var buttonVal: u64 = 0;
                var buttonSplit = std.mem.splitScalar(u8, part[1 .. part.len - 1], ',');
                while (buttonSplit.next()) |buttonPart| {
                    buttonVal |= @as(u64, 1) << try Utils.parseInt(u6, buttonPart);
                }
                try buttons.append(utils.alloc, buttonVal);
            } else {
                var joltageSplit = std.mem.splitScalar(u8, part[1 .. part.len - 1], ',');
                while (joltageSplit.next()) |joltagePart| {
                    try joltage.append(utils.alloc, try Utils.parseInt(u64, joltagePart));
                }
            }
        }

        try machines.append(utils.alloc, .{
            .targetState = targetState,
            .maxState = maxState,
            .buttons = try buttons.toOwnedSlice(utils.alloc),
            .joltage = try joltage.toOwnedSlice(utils.alloc),
        });
    }

    success = true;
    return machines.toOwnedSlice(utils.alloc);
}
