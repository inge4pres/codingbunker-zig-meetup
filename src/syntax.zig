//! Welcome to Zig!
//! In this file, you can see in action some of features of the Zig language.
//! The list is non-exclusive, and you can find more in the official documentation.

// Import the standard library
const std = @import("std");

// mutability
test "const and var" {
    const a: i32 = 42;

    const b = a;
    var c = &a;

    std.debug.print("a is {}, b is {}, c is {}\n", .{ @TypeOf(a), @TypeOf(b), @TypeOf(c) });

    b = c;
    c.* = 73;
    c = undefined;
}

// enums and ADTs

/// Pet defines tha animals that can be domesticated.
const Pet = enum {
    Dog,
    Cat,
    Parrot,
    Lizard,

    /// Display the sound of each pet.
    // Enums can have methods.
    fn sound(p: Pet) []const u8 {
        return switch (p) {
            Pet.Dog => "woof",
            Pet.Cat => "meow",
            Pet.Parrot => "squawk",
        };
    }
};

/// Animal is the set of type of animals we can encounter.
const Aninmal = union {
    Domestic: Pet,
    Wild: []const u8,
};

/// Characterize the feeding of each pet.
const Feeding = union(Pet) {
    Dog: []const u8,
    Cat: void,
    Parrot: u32,
    Lizard: f32,
};

test "enums" {
    const dog = Pet.Dog;
    const parrot = Pet.Parrot;
    std.debug.print("dog says {s}, parrot replies {s}\n", .{ dog.sound(), parrot.sound() });
}

test "optionals" {
    const a: ?i32 = 42;
    const b: ?i32 = null;

    // unwraps the optional into "value" if it is not null
    if (a) |value| {
        std.debug.print("a is {}\n", .{value});
    } else std.debug.print("a is null\n", .{});

    // specifically for printing, we can rely on '?'' or 'any'
    std.debug.print("a is {?}, b is {?}\n", .{ a, b });

    const defaultVal = b orelse 42;
    try std.testing.expectEqual(42, defaultVal);
}

test "defer and errdefer" {
    var a: u32 = 1;
    {
        defer a += 1;
        std.debug.print("a is {}\n", .{a});
    }
    std.debug.print("a is {}\n", .{a});

    errdefer {
        std.debug.print("test assertion failed, executing errdefer\n", .{});
    }
    // Fail the test on purpose to let errdefer run
    try std.testing.expectEqual(0, a);
}

/// DotFileError is the set of errors that can occur when creating a dot file.
// Define an error set, merging custom errors with standard library errors.
const DotFileError = error{ InvalidName, InvalidPath } || std.fs.File.OpenError;

fn createDotFile(comptime name: []const u8, comptime directory: []const u8) DotFileError!void {
    if (name[0] != '.') {
        return DotFileError.InvalidName;
    }
    // we are not interested in the file returned
    _ = try std.fs.createFileAbsolute(
        directory ++ std.fs.path.sep_str ++ name,
        // An error is returned if the file already exists
        .{ .exclusive = true },
    );
}

// deomnstrate error handling
test "results" {
    const out = try std.fmt.allocPrint(
        std.testing.allocator,
        "{d} is {s}\n",
        .{ 42, "the meaning of life" },
    );
    defer std.testing.allocator.free(out);

    try std.testing.expectEqualStrings(out, "42 is the meaning of life\n");

    const result = createDotFile("will_fail", "/tmp");
    try std.testing.expectError(DotFileError.InvalidName, result);

    // works, and we need to cleanup the file after the test
    try createDotFile(".some_config", "/tmp");
    defer std.fs.deleteFileAbsolute("/tmp/.some_config") catch unreachable;

    // assert failure
    const duped = createDotFile(".some_config", "/tmp");
    try std.testing.expectError(std.fs.File.OpenError.PathAlreadyExists, duped);

    // we can switch on the error type if the error set is defined
    createDotFile(".some_config", "/tmp") catch |e| switch (e) {
        error.InvalidName => std.debug.print("wrong input: {?}\n", .{e}),
        else => |err| std.debug.print("catch   | filesystem error: {?}\n", .{err}),
    };

    // unwrapping function error(s) equally as above, with a different syntax based on if/else.
    // the if branch can capture the returned successful value
    if (createDotFile(".some_config", "/tmp")) |_| {} else |e| switch (e) {
        error.InvalidName => std.debug.print("wrong input: {?}\n", .{e}),
        else => |err| std.debug.print("if else | filesystem error: {?}\n", .{err}),
    }
}

// "threadlocal" allows declaring a variable that is unique to each thread.
// A threadlocal assignment cannot be const.
threadlocal var local: u6 = 42;

test "threadlocal" {
    const t1 = try std.Thread.spawn(.{}, localAddOne, .{42});
    const t2 = try std.Thread.spawn(.{}, localAddOne, .{42});

    localAddOne(42);

    t1.join();
    t2.join();
}

fn localAddOne(baseVal: u6) void {
    // All 3 threads refer to the same variable, but each one modifies its own copy.
    local += 1;
    std.testing.expectEqual(baseVal + 1, local) catch unreachable;
}

// packed structs allow defining memory layout for a struct.

/// Coordinates is a point in 2D positive coordinates space.
const Coordinates = packed struct {
    x: u16,
    y: u16,
};

test "packed struct" {
    const point = Coordinates{ .x = 4, .y = 2 };

    // in binary, 4 and 2
    const val: [2]u16 = .{ 0b100, 0b10 };
    // @bitCast converts the binary represnetation into a type,
    // the inferred type is on the left side
    const binPoint: Coordinates = @bitCast(val);

    // same as above, reading from memory
    // binary encoding for free!
    const binPointFromMem: Coordinates = @bitCast(std.mem.toBytes(point));

    // the entire struct fits into 4 bytes
    try std.testing.expectEqual(4, @sizeOf(Coordinates));
    try std.testing.expectEqualDeep(point, binPoint);
    try std.testing.expectEqualDeep(point, binPointFromMem);
}
