const std = @import("std");
const fs = std.fs;

const Allocator = std.mem.Allocator;
const StrArray = std.ArrayList([]const u8);
const DictMap = std.StringHashMap(StrArray);

pub fn countTokens(line: []const u8) !u32 {
    var split = std.mem.tokenize(u8, line, " ");

    var count: u32 = 0;
    while (split.next() != null) : (count += 1) {}
    return count;
}

pub fn analyzeFile(dir: fs.Dir, path: []const u8, map: *DictMap, allocator: Allocator) !void {
    var file = try dir.openFile(path, .{});
    defer file.close();

    var bufferedReader = std.io.bufferedReader(file.reader());
    var inStream = bufferedReader.reader();

    var strArray = StrArray.init(allocator);

    var buf: [1024]u8 = undefined;
    var wcount: u32 = 0;
    var lcount: u32 = 0;
    while (try inStream.readUntilDelimiterOrEof(&buf, '\n')) |line| : (lcount += 1) {
        try strArray.append(line);
        wcount += try countTokens(line);
    }
    try map.put(path, strArray);
    std.log.info("line count: {d}\tword count: {d}", .{ lcount, wcount });
}

pub fn buildMap(allocator: Allocator) !DictMap {
    var currentDir = try fs.cwd().openIterableDir(".", .{});
    defer currentDir.close();

    var dictMap = DictMap.init(allocator);

    var iter = currentDir.iterate();
    while (try iter.next()) |entry| {
        switch (entry.kind) {
            .Directory => {
                std.log.info("Directory: {s}", .{entry.name});
            },
            .File => {
                std.log.info("File: {s}", .{entry.name});
                try analyzeFile(currentDir.dir, entry.name, &dictMap, allocator);
            },
            else => {},
        }
    }

    return dictMap;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var dictMap = try buildMap(gpa.allocator());
    defer dictMap.deinit();
}
