const Utils = @import("aoc2025").Utils;
const std = @import("std");

const Vertex = struct {
    x: u64,
    y: u64,
    z: u64,

    fn distanceSq(self: *const Vertex, other: Vertex) u64 {
        const dx = Utils.cast(i64, self.x) - Utils.cast(i64, other.x);
        const dy = Utils.cast(i64, self.y) - Utils.cast(i64, other.y);
        const dz = Utils.cast(i64, self.z) - Utils.cast(i64, other.z);
        return Utils.cast(u64, dx * dx + dy * dy + dz * dz);
    }
};

const Edge = struct {
    a: usize,
    b: usize,
};

fn edgeLessThan(vertices: []Vertex, first: Edge, second: Edge) bool {
    const firstA = vertices[first.a];
    const firstB = vertices[first.b];
    const secondA = vertices[second.a];
    const secondB = vertices[second.b];
    return firstA.distanceSq(firstB) < secondA.distanceSq(secondB);
}

pub fn part1(utils: *Utils) !void {
    try solve(utils, 1000);
}

pub fn part2(utils: *Utils) !void {
    try solve(utils, null);
}

fn solve(utils: *Utils, maxIters: ?usize) !void {
    var vertices = std.ArrayList(Vertex).empty;
    defer vertices.deinit(utils.alloc);

    while (!utils.inputEnded) {
        const line = try utils.readInputLine();
        defer utils.alloc.free(line);

        var split = std.mem.splitScalar(u8, line, ',');
        const x = split.next();
        const y = split.next();
        const z = split.next();
        if (x != null and y != null and z != null) {
            try vertices.append(utils.alloc, .{ .x = try Utils.parseInt(u64, x.?), .y = try Utils.parseInt(u64, y.?), .z = try Utils.parseInt(u64, z.?) });
        }
    }

    var edges = try utils.alloc.alloc(Edge, (vertices.items.len * (vertices.items.len - 1)) / 2);
    defer utils.alloc.free(edges);
    var edgeI: usize = 0;
    for (0..vertices.items.len - 1) |a| {
        for (a + 1..vertices.items.len) |b| {
            edges[edgeI] = .{ .a = a, .b = b };
            edgeI += 1;
        }
    }

    std.mem.sort(Edge, edges, vertices.items, edgeLessThan);

    var groups = try utils.alloc.alloc(usize, vertices.items.len);
    defer utils.alloc.free(groups);
    for (0..groups.len) |i| {
        groups[i] = i;
    }

    var counter: usize = 0;
    var connectionCount: usize = 0;
    for (edges) |edge| {
        if (counter == maxIters) {
            break;
        }
        counter += 1;

        const groupA = groups[edge.a];
        const groupB = groups[edge.b];

        if (groupA == groupB) {
            continue;
        }
        for (groups) |*group| {
            if (group.* == groupB) {
                group.* = groupA;
            }
        }

        connectionCount += 1;
        if (connectionCount + 1 == vertices.items.len) {
            try utils.print("{d}", .{vertices.items[edge.a].x * vertices.items[edge.b].x});
            return;
        }
    }

    var counts = try utils.alloc.alloc(u64, groups.len);
    defer utils.alloc.free(counts);
    @memset(counts, 0);

    for (groups) |group| {
        counts[group] += 1;
    }

    std.mem.sort(u64, counts, {}, comptime std.sort.desc(u64));
    try utils.print("{d}", .{counts[0] * counts[1] * counts[2]});
}
