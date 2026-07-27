const std = @import("std");

pub fn main() !void{
    var very_big_alloc: [1000 * 1000 * 24]u64 = undefined;
    @memset(very_big_alloc[0..], 0);
}