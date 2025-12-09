const Utils = @import("aoc2025").Utils;
const std = @import("std");

const Point = struct {
    x: u64,
    y: u64,

    fn areaTo(self: *const Point, other: Point) u64 {
        const dx = Utils.cast(i64, self.x) - Utils.cast(i64, other.x) + 1;
        const dy = Utils.cast(i64, self.y) - Utils.cast(i64, other.y) + 1;
        return Utils.cast(u64, @abs(dx * dy));
    }

    fn dirTo(self: *const Point, other: Point) Direction {
        if (self.x == other.x) {
            if (self.y < other.y) {
                return Direction.down;
            } else {
                return Direction.up;
            }
        } else {
            if (self.x < other.x) {
                return Direction.right;
            } else {
                return Direction.left;
            }
        }
    }
};

const Direction = enum(u8) {
    up,
    right,
    down,
    left,

    fn angleTo(self: *const Direction, other: Direction) i64 {
        const selfI = @intFromEnum(self.*);
        const otherI = @intFromEnum(other);
        const delta = (otherI -% selfI) % 4;
        return if (delta == 3) -1 else @as(i64, delta);
    }

    fn isHorizontal(self: *const Direction) bool {
        return (@intFromEnum(self.*) & 1) != 0;
    }
};

fn lineInterceptsPolygon(a: Point, b: Point, polygon: []const Point, leftOnOutside: bool) bool {
    _ = leftOnOutside;
    if (a.x == b.x) {
        for (@min(a.y, b.y)..@max(a.y, b.y) + 1) |y| {
            if (!isInsidePolygon(.{ .x = a.x, .y = Utils.cast(u64, y) }, polygon)) {
                return true;
            }
        }
    } else {
        for (@min(a.x, b.x)..@max(a.x, b.x) + 1) |x| {
            if (!isInsidePolygon(.{ .x = Utils.cast(u64, x), .y = a.y }, polygon)) {
                return true;
            }
        }
    }

    return false;
}

fn isInsidePolygon(p: Point, polygon: []const Point) bool {
    var leftCount: usize = 0;
    for (0..polygon.len) |i| {
        const polygonA = polygon[i];
        const polygonB = polygon[(i + 1) % polygon.len];
        if (polygonA.y == polygonB.y) {
            // horizontal line
            if (polygonA.y == p.y) {
                if (p.x >= @min(polygonA.x, polygonB.x) and p.x <= @max(polygonA.x, polygonB.x)) {
                    return true;
                } else if (p.x > @max(polygonA.x, polygonB.x)) {
                    const polygonC = if (i == 0) polygon[polygon.len - 1] else polygon[i - 1];
                    const polygonD = polygon[(i + 2) % polygon.len];
                    if ((p.y < polygonC.y) != (p.y < polygonD.y)) {
                        leftCount += 1;
                    }
                }
            }
        } else {
            // vertical line
            if (p.y >= @min(polygonA.y, polygonB.y) and p.y <= @max(polygonA.y, polygonB.y)) {
                if (polygonA.x == p.x) {
                    return true;
                } else if (polygonA.x < p.x) {
                    leftCount += 1;
                }
            }
        }
    }

    return leftCount % 2 == 1;
}

fn rectInterceptsPolygon(a: Point, b: Point, polygon: []const Point, leftOnOutside: bool) bool {
    if (a.x == b.x or a.y == b.y) {
        return false;
    }

    if (lineInterceptsPolygon(a, .{ .x = b.x, .y = a.y }, polygon, leftOnOutside)) {
        return true;
    }
    if (lineInterceptsPolygon(.{ .x = b.x, .y = a.y }, b, polygon, leftOnOutside)) {
        return true;
    }
    if (lineInterceptsPolygon(b, .{ .x = a.x, .y = b.y }, polygon, leftOnOutside)) {
        return true;
    }
    return lineInterceptsPolygon(.{ .x = a.x, .y = b.y }, a, polygon, leftOnOutside);
}

pub fn part1(utils: *Utils) !void {
    var points = std.ArrayList(Point).empty;
    defer points.deinit(utils.alloc);

    while (!utils.inputEnded) {
        const line = try utils.readInputLine();
        defer utils.alloc.free(line);

        var split = std.mem.splitScalar(u8, line, ',');
        const x = split.next();
        const y = split.next();
        if (x != null and y != null) {
            try points.append(utils.alloc, .{ .x = try Utils.parseInt(u64, x.?), .y = try Utils.parseInt(u64, y.?) });
        }
    }

    var maxArea: u64 = 0;
    for (0..points.items.len - 1) |i| {
        for (i + 1..points.items.len) |j| {
            maxArea = @max(maxArea, points.items[i].areaTo(points.items[j]));
        }
    }

    try utils.print("{d}", .{maxArea});
}

pub fn part2(utils: *Utils) !void {
    var points = std.ArrayList(Point).empty;
    defer points.deinit(utils.alloc);

    while (!utils.inputEnded) {
        const line = try utils.readInputLine();
        defer utils.alloc.free(line);

        var split = std.mem.splitScalar(u8, line, ',');
        const x = split.next();
        const y = split.next();
        if (x != null and y != null) {
            try points.append(utils.alloc, .{ .x = try Utils.parseInt(u64, x.?), .y = try Utils.parseInt(u64, y.?) });
        }
    }

    var angle: i64 = 0;
    var prevDir = points.getLast().dirTo(points.items[0]);
    for (1..points.items.len) |i| {
        const dir = points.items[i - 1].dirTo(points.items[i]);
        angle += prevDir.angleTo(dir);
        prevDir = dir;
    }

    const leftOnOutside = angle > 0;

    var maxArea: u64 = 0;
    var finishedThreads: usize = 0;
    for (0..points.items.len - 1) |i| {
        _ = try std.Thread.spawn(.{}, part2Iter, .{ i, points.items, leftOnOutside, &maxArea, &finishedThreads });
    }

    while (finishedThreads < points.items.len - 1) {
        std.Thread.sleep(1000000);
    }

    try utils.print("{d}", .{maxArea});
}

fn part2Iter(i: usize, points: []const Point, leftOnOutside: bool, maxArea: *u64, finishedThreads: *usize) !void {
    for (i + 1..points.len) |j| {
        std.debug.print("{d}, {d}\n", .{ i, j });
        const area = points[i].areaTo(points[j]);
        if (area >= maxArea.*) {
            continue;
        }
        if (rectInterceptsPolygon(points[i], points[j], points, leftOnOutside)) {
            continue;
        }
        while (true) {
            const oldValue = maxArea.*;
            if (area >= oldValue) {
                break;
            }
            if (@cmpxchgWeak(u64, maxArea, oldValue, area, std.builtin.AtomicOrder.acquire, std.builtin.AtomicOrder.acquire) == null) {
                break;
            }
        }
    }

    while (true) {
        const oldValue = finishedThreads.*;
        if (@cmpxchgWeak(usize, finishedThreads, oldValue, oldValue + 1, std.builtin.AtomicOrder.acquire, std.builtin.AtomicOrder.acquire) == null) {
            break;
        }
    }
}
