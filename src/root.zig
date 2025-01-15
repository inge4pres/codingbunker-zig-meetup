const std = @import("std");
const testing = std.testing;

export fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "basic add functionality" {
    try testing.expect(add(3, 7) == 10);
}

// Allow the execution of tests of other files as part of lib unit tests
test {
    _ = @import("syntax.zig");
    _ = @import("comptime.zig");
}
