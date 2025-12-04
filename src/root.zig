//! By convention, root.zig is the root source file when making a library.
const std = @import("std");

pub const Utils = struct {
    alloc: std.mem.Allocator,
    buffer: [1024]u8,
    inputReader: *std.io.Reader,
    inputEnded: bool,

    pub fn print(self: *Utils, comptime fmt: []const u8, args: anytype) !void {
        var writer = std.fs.File.stdout().writer(&self.buffer);
        const stdout = &writer.interface;
        try stdout.print(fmt ++ "\n", args);
        try stdout.flush();
    }

    pub fn readStdinLine(self: *Utils) ![]u8 {
        var reader = std.fs.File.stdin().reader(&self.buffer);
        const result = try self.readLineWithReader(&reader.interface);
        return result.result;
    }

    pub fn readInputLine(self: *Utils) ![]u8 {
        const result = try self.readLineWithReader(self.inputReader);
        self.inputEnded = result.ended;
        return result.result;
    }

    fn readLineWithReader(self: *Utils, reader: *std.io.Reader) !struct { result: []u8, ended: bool } {
        var result = std.io.Writer.Allocating.init(self.alloc);
        defer result.deinit();
        _ = try reader.streamDelimiterEnding(&result.writer, '\n');

        _ = reader.takeByte() catch |err| switch (err) {
            error.EndOfStream => {
                return .{ .result = try result.toOwnedSlice(), .ended = true };
            },
            else => return err,
        };
        return .{ .result = try result.toOwnedSlice(), .ended = false };
    }

    pub fn parseInt(comptime T: type, value: []const u8) !T {
        return std.fmt.parseInt(T, value, 10);
    }

    pub fn cast(comptime T: type, v: anytype) T {
        return @intCast(v);
    }
};
