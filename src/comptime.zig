const std = @import("std");

test "comptime assert" {
    const a = 1;
    const b = 2;
    const c: comptime_int = a + b;

    // This will fail at compile time
    try comptime std.testing.expectEqual(c, 3);
}

test Observer {
    var counter = Observer(u128){ .inner = 0 };
    counter.update(&counterIncr);

    try std.testing.expectEqual(counter.inner, 1);
}

/// Observer propagates the changes to the inner value using the provided function.
pub fn Observer(comptime T: type) type {
    return struct {
        inner: T,

        // Since we want to re-assign the inner value, we need a pointer.
        // This allows mutability, because in Zig all function arguments are immutable.
        pub fn update(self: *@This(), change: *const fn (arg: T) T) void {
            self.inner = change(self.inner);
        }
    };
}

/// Increments monotonically the value by one.
pub fn counterIncr(value: u128) u128 {
    return add(u128, value, 1);
}

// Pure generic function
fn add(comptime T: type, value: T, delta: T) T {
    return value + delta;
}

// Inline loops allow to copy the loop into all possible compile-time knwon variations.
test "inline loops" {
    comptime var sum: comptime_int = 0;
    inline for (1..5) |i| {
        sum += i;
    }

    try comptime std.testing.expectEqual(sum, 10);
}
