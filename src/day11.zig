const Utils = @import("aoc2025").Utils;
const std = @import("std");

const NodeId = [3]u8;

const Graph = std.AutoHashMap(NodeId, []const NodeId);

fn deinitGraph(utils: *Utils, graph: *Graph) void {
    var values = graph.valueIterator();
    while (values.next()) |value| {
        utils.alloc.free(value.*);
    }
    graph.deinit();
}

pub fn part1(utils: *Utils) !void {
    var graph = try parseGraph(utils);
    defer deinitGraph(utils, &graph);

    const keysInOrder = try topoSort(utils, &graph);

    var numberOfPaths = std.AutoHashMap(NodeId, u64).init(utils.alloc);
    defer numberOfPaths.deinit();
    try numberOfPaths.put("you".*, 1);

    for (keysInOrder) |key| {
        if (numberOfPaths.get(key)) |count| {
            if (graph.get(key)) |succs| {
                for (succs) |succ| {
                    const entry = try numberOfPaths.getOrPutValue(succ, 0);
                    entry.value_ptr.* += count;
                }
            }
        }
    }

    try utils.print("{d}", .{numberOfPaths.get("out".*).?});
}

pub fn part2(utils: *Utils) !void {
    var graph = try parseGraph(utils);
    defer deinitGraph(utils, &graph);

    const keysInOrder = try topoSort(utils, &graph);

    const PathNode = struct {
        node: NodeId,
        visitedViaNodes: u2,
    };

    var numberOfPaths = std.AutoHashMap(PathNode, u64).init(utils.alloc);
    defer numberOfPaths.deinit();
    try numberOfPaths.put(.{ .node = "svr".*, .visitedViaNodes = 0 }, 1);

    for (keysInOrder) |key| {
        for (0..4) |i| {
            const visitedViaNodes = Utils.cast(u2, i);

            if (numberOfPaths.get(.{ .node = key, .visitedViaNodes = visitedViaNodes })) |count| {
                if (graph.get(key)) |succs| {
                    for (succs) |succ| {
                        var newVisitedViaNodes = visitedViaNodes;
                        if (std.meta.eql(succ, "dac".*)) {
                            newVisitedViaNodes |= 1;
                        } else if (std.meta.eql(succ, "fft".*)) {
                            newVisitedViaNodes |= 2;
                        }
                        const entry = try numberOfPaths.getOrPutValue(.{ .node = succ, .visitedViaNodes = newVisitedViaNodes }, 0);
                        entry.value_ptr.* += count;
                    }
                }
            }
        }
    }

    try utils.print("{d}", .{numberOfPaths.get(.{ .node = "out".*, .visitedViaNodes = 3 }).?});
}

fn topoSort(utils: *Utils, graph: *const Graph) ![]NodeId {
    var inDegree = std.AutoHashMap(NodeId, u64).init(utils.alloc);
    defer inDegree.deinit();

    var keys = graph.keyIterator();
    while (keys.next()) |n| {
        try inDegree.put(n.*, 0);
    }

    var values = graph.valueIterator();
    while (values.next()) |succs| {
        for (succs.*) |succ| {
            (try inDegree.getOrPutValue(succ, 0)).value_ptr.* += 1;
        }
    }

    var result = std.ArrayList(NodeId).empty;
    defer result.deinit(utils.alloc);
    while (inDegree.count() != 0) {
        var zeroInDegrees = std.ArrayList(NodeId).empty;
        defer zeroInDegrees.deinit(utils.alloc);

        var itr = inDegree.iterator();
        while (itr.next()) |entry| {
            if (entry.value_ptr.* == 0) {
                try zeroInDegrees.append(utils.alloc, entry.key_ptr.*);
            }
        }

        try result.appendSlice(utils.alloc, zeroInDegrees.items);

        for (zeroInDegrees.items) |node| {
            if (graph.get(node)) |succs| {
                for (succs) |succ| {
                    if (inDegree.getPtr(succ)) |succInDegree| {
                        succInDegree.* -= 1;
                    }
                }
            }
            _ = inDegree.remove(node);
        }
    }

    return try result.toOwnedSlice(utils.alloc);
}

fn parseGraph(utils: *Utils) !Graph {
    var graph = Graph.init(utils.alloc);
    var success = false;
    defer {
        if (!success) {
            deinitGraph(utils, &graph);
        }
    }

    while (!utils.inputEnded) {
        const line = try utils.readInputLine();
        defer utils.alloc.free(line);
        var split = std.mem.splitScalar(u8, line, ' ');

        const keyStr = split.next().?;
        if (keyStr.len != 4) {
            continue;
        }
        const key: NodeId = keyStr[0..3].*;

        var succs = std.ArrayList(NodeId).empty;
        defer succs.deinit(utils.alloc);
        while (split.next()) |succ| {
            if (succ.len != 3) {
                continue;
            }
            try succs.append(utils.alloc, succ[0..3].*);
        }

        try graph.putNoClobber(key, try succs.toOwnedSlice(utils.alloc));
    }

    success = true;
    return graph;
}
