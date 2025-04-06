const std = @import("std");

const dlib = std.DynLib;

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});
    try bw.flush(); // Don't forget to flush!
    var buffer: [1000]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    const argv = std.process.argsAlloc(allocator);
    const dynamicFn = argv catch @panic("YOU DONE GOOFED");
    defer std.process.argsFree(allocator, dynamicFn);

    var dl_opened = dlib.open(dynamicFn[1]) catch @panic("YOU LIBRARY GOOFIN");
    var afn: *const fn () void = undefined;
    afn = dl_opened.lookup(@TypeOf(afn), "Afn") orelse @panic("YOUR FUNCTION DONE GOOFED");
    afn();
}
