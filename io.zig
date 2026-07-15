const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const read_buf: [4096]u8 = undefined;
    const write_buf: [4096]u8 = undefined;

    const stdout_file = std.Io.File.stdout();
    const stdin_file = std.Io.File.stdin();

    const  stdout_writer = stdout_file.writer(io,write_buf);
    const  stdin_reader = stdin_file.writer(io,read_buf);

    const stdout = &stdout_writer.interface;
    _ = &stdin_reader.interface;

    stdout.print("hello world",.{});
    stdout.flush();
}