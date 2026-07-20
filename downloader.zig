const std = @import("std");
const Io = std.Io;

const parallel_requests = 10;
const worker_limit = 20;

pub fn main(init: std.process.Init) !u8 {
    const args = try init.minimal.args.toSlice(init.arena.allocator());
    if (args.len != 2) {
        std.debug.print("Usage: file_downloader_gist <link>\n", .{});
        return 2;
    }

    var threaded: Io.Threaded = .init(init.gpa, .{
        .async_limit = .limited(parallel_requests),
        .concurrent_limit = .limited(worker_limit),
    });
    defer threaded.deinit();
    const io = threaded.io();

    const uri = std.Uri.parse(args[1]) catch |err| {
        std.debug.print("{t}\n", .{err});
        return 1;
    };

    var client: std.http.Client = .{
        .allocator = init.gpa,
        .io = io,
    };
    defer client.deinit();

    const destination = destinationName(uri);
    const bytes_written = download(&client, .cwd(), uri, destination) catch |err| {
        std.debug.print("{t}\n", .{err});
        return 1;
    };

    std.debug.print("saved {s} ({d} bytes)\n", .{ destination, bytes_written });
    return 0;
}

fn destinationName(uri: std.Uri) []const u8 {
    const basename = Io.Dir.path.basenamePosix(uri.path.percent_encoded);
    return if (basename.len == 0) "download" else basename;
}

fn remoteFileSize(client: *std.http.Client, uri: std.Uri) !u64 {
    var request = try client.request(.HEAD, uri, .{
        .headers = .{ .accept_encoding = .{ .override = "identity" } },
    });
    defer request.deinit();
    try request.sendBodiless();

    var head_buffer: [8192]u8 = undefined;
    const response = try request.receiveHead(&head_buffer);

    if (response.head.status != .ok) return error.UnexpectedHttpStatus;
    return response.head.content_length orelse error.MissingContentLength;
}

fn download(
    client: *std.http.Client,
    destination_dir: Io.Dir,
    uri: std.Uri,
    destination: []const u8,
) !u64 {
    const io = client.io;
    const total = try remoteFileSize(client, uri);

    var file = try destination_dir.createFile(io, destination, .{});
    defer file.close(io);
    if (total == 0) return 0;

    const chunk_count: usize = @intCast(@min(total, parallel_requests));
    var futures: [parallel_requests]Io.Future(anyerror!void) = undefined;
    var started: usize = 0;
    defer for (futures[0..started]) |*future| {
        _ = future.cancel(io) catch {};
    };

    const base_len = total / chunk_count;
    const remainder = total % chunk_count;
    var start: u64 = 0;

    for (futures[0..chunk_count], 0..) |*future, chunk_index| {
        const chunk_len = base_len + @intFromBool(chunk_index < remainder);
        future.* = try io.concurrent(downloadChunk, .{
            client,
            file,
            uri,
            start,
            start + chunk_len - 1,
        });
        started += 1;
        start += chunk_len;
    }

    for (futures[0..chunk_count]) |*future| {
        try future.await(io);
    }

    return total;
}

fn downloadChunk(
    client: *std.http.Client,
    file: Io.File,
    uri: std.Uri,
    start: u64,
    end: u64,
) anyerror!void {
    const io = client.io;

    var range_buffer: [128]u8 = undefined;
    const range = try std.fmt.bufPrint(
        &range_buffer,
        "bytes={d}-{d}",
        .{ start, end },
    );

    var file_buffer: [64 * 1024]u8 = undefined;
    var writer = file.writer(io, &file_buffer);
    try writer.seekTo(start);

    const response = try client.fetch(.{
        .location = .{ .uri = uri },
        .response_writer = &writer.interface,
        .headers = .{ .accept_encoding = .{ .override = "identity" } },
        .extra_headers = &.{
            .{ .name = "Range", .value = range },
        },
    });

    if (response.status != .partial_content) return error.RangeRequestRejected;
    if (writer.logicalPos() != end + 1) return error.UnexpectedContentLength;
    try writer.flush();
}