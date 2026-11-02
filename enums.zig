const std = @import("std");

/// this is an enum  with a function
const fruits = enum {
    mango,
    apple,
    orange,

    pub fn print(self: fruits) void {
        return switch (self) {
            .mango => std.debug.print("{s}\n", .{@tagName(self)}),
            .apple => std.debug.print("{s}\n", .{@tagName(self)}),
            .orange => std.debug.print("{s}\n", .{@tagName(self)}),
        };
    }
};

/// this is a bare union
const Number = union { int: u32, float: f32 };

/// this is a tagged union
const Shape = union(enum) {
    circle: f32, // radius
    square: f32, // side length
    rectangle: struct { width: f32, height: f32 },
    point, // no data at all

    pub fn area(self: Shape) f32 {
        return switch (self) {
            .circle => |r| std.math.pi * r * r,
            .square => |side| side * side,
            .rectangle => |rect| rect.width * rect.height,
            .point => 0,
        };
    }
};

pub fn main() void {
    var n = Number{ .int = 20 };
    std.debug.print("{d}\n", .{n.int}); // fine, int is active

    n = Number{ .float = 200.222 };
    std.debug.print("{d}\n", .{n.float}); // float is active int will be inactive here
    std.debug.print("Mango: {any}\n", .{fruits.mango});
    const fruit: fruits = .apple;
    fruit.print();

    const a = Shape{ .circle = 2.0 };
    const b = Shape{ .rectangle = .{ .width = 3.0, .height = 4.0 } };
    const c: Shape = .point;

    std.debug.print("{d:.2}\n", .{a.area()}); // 12.57
    std.debug.print("{d:.2}\n", .{b.area()}); // 12.00
    std.debug.print("{d:.2}\n", .{c.area()}); // 0.00
}
