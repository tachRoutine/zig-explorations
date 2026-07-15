const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var read_buf: [4096]u8 = undefined;
    var write_buf: [4096]u8 = undefined;

    const stdout_file = std.Io.File.stdout();
    const stdin_file = std.Io.File.stdin();

    var  stdout_writer = stdout_file.writer(io,&write_buf);
    var  stdin_reader = stdin_file.writer(io,&read_buf);

    var stdout = &stdout_writer.interface;
    _ = &stdin_reader.interface;

    try stdout.print("hello world",.{});
    try stdout.flush();
}