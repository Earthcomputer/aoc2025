const Utils = @import("aoc2025").Utils;
const std = @import("std");

const Operator = enum {
    plus,
    multiply,
};

pub fn part1(utils: *Utils) !void {
    var numbers = std.ArrayList([]u64).empty;
    defer {
        for (numbers.items) |numberRow| {
            utils.alloc.free(numberRow);
        }
        numbers.deinit(utils.alloc);
    }

    var operators = std.ArrayList(Operator).empty;
    defer operators.deinit(utils.alloc);

    while (!utils.inputEnded) {
        const line = try utils.readInputLine();
        defer utils.alloc.free(line);

        if (std.mem.startsWith(u8, line, "+") or std.mem.startsWith(u8, line, "*")) {
            for (line) |ch| {
                switch (ch) {
                    '+' => try operators.append(utils.alloc, Operator.plus),
                    '*' => try operators.append(utils.alloc, Operator.multiply),
                    else => {},
                }
            }
        } else {
            var numberRow = std.ArrayList(u64).empty;
            defer numberRow.deinit(utils.alloc);

            var numberItr = std.mem.splitScalar(u8, line, ' ');
            while (numberItr.next()) |numberStr| {
                if (numberStr.len != 0) {
                    try numberRow.append(utils.alloc, try Utils.parseInt(u64, numberStr));
                }
            }

            try numbers.append(utils.alloc, try numberRow.toOwnedSlice(utils.alloc));
        }
    }

    var total: u64 = 0;
    for (0..operators.items.len) |i| {
        switch (operators.items[i]) {
            Operator.plus => {
                for (numbers.items) |numberRow| {
                    if (i < numberRow.len) {
                        total += numberRow[i];
                    }
                }
            },
            Operator.multiply => {
                var product: u64 = 1;
                for (numbers.items) |numberRow| {
                    if (i < numberRow.len) {
                        product *= numberRow[i];
                    }
                }
                total += product;
            },
        }
    }

    try utils.print("{d}", .{total});
}

pub fn part2(utils: *Utils) !void {
    var lines = std.ArrayList([]u8).empty;
    defer {
        for (lines.items) |line| {
            utils.alloc.free(line);
        }
        lines.deinit(utils.alloc);
    }

    while (!utils.inputEnded) {
        const line = try utils.readInputLine();
        if (line.len != 0) {
            try lines.append(utils.alloc, line);
        } else {
            utils.alloc.free(line);
        }
    }

    var total: u64 = 0;
    var currentTotal: u64 = 0;
    var currentOperator = Operator.plus;
    for (0..lines.getLast().len) |i| {
        switch (lines.getLast()[i]) {
            '+' => {
                total += currentTotal;
                currentTotal = 0;
                currentOperator = Operator.plus;
            },
            '*' => {
                total += currentTotal;
                currentTotal = 1;
                currentOperator = Operator.multiply;
            },
            else => {
                if (i + 1 < lines.getLast().len and lines.getLast()[i + 1] != ' ') {
                    continue;
                }
            },
        }

        var currentValue: u64 = 0;
        for (0..lines.items.len - 1) |j| {
            if (lines.items[j][i] != ' ') {
                currentValue = currentValue * 10 + try std.fmt.charToDigit(lines.items[j][i], 10);
            }
        }

        switch (currentOperator) {
            Operator.plus => {
                currentTotal += currentValue;
            },
            Operator.multiply => {
                currentTotal *= currentValue;
            },
        }
    }

    total += currentTotal;

    try utils.print("{d}", .{total});
}
