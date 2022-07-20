const std = @import("std");
const fs = std.fs;

pub fn main() anyerror!void {
    // const stdout = std.io.getStdOut().writer();

    std.log.info("All your codebase are belong to us.", .{});

    var currentDir = fs.cwd().openIterableDir(".", .{});
    for (currentDir) |x| {
        std.log.info("filename: {0}\n", .{x});
    }
}
