const std = @import("std");
const xcode_frameworks = @import("xcode_frameworks");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "tracy",
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibC();
    lib.linkLibCpp();
    if (target.isWindows()) {
        lib.linkSystemLibrary("Advapi32");
        lib.linkSystemLibrary("User32");
        lib.linkSystemLibrary("Ws2_32");
        lib.linkSystemLibrary("DbgHelp");
    }
    if (target.isDarwin()) {
        try xcode_frameworks.addPaths(b, lib);
    }

    lib.addIncludePath(.{ .path = "upstream" });

    var flags = std.ArrayList([]const u8).init(b.allocator);
    defer flags.deinit();
    try flags.appendSlice(&.{
        "-DTRACY_ENABLE",
        "-fno-sanitize=undefined",
    });
    if (target.isWindows()) {
        try flags.appendSlice(&.{
            "-D_WIN32_WINNT=0x601",
        });
    }

    lib.addCSourceFile(.{
        .file = .{ .path = "upstream/TracyClient.cpp" },
        .flags = flags.items,
    });

    inline for (headers) |header| {
        lib.installHeader("upstream/" ++ header, header);
    }

    b.installArtifact(lib);
}

const headers = &.{
    "TracyC.h",
    "TracyOpenGL.hpp",
    "Tracy.hpp",
    "TracyD3D11.hpp",
    "TracyD3D12.hpp",
    "TracyOpenCL.hpp",
    "TracyVulkan.hpp",
    "client/TracyCallstack.h",
    "client/TracyScoped.hpp",
    "client/TracyStringHelpers.hpp",
    "client/TracySysTrace.hpp",
    "client/TracyDxt1.hpp",
    "client/TracyRingBuffer.hpp",
    "client/tracy_rpmalloc.hpp",
    "client/TracyDebug.hpp",
    "client/TracyLock.hpp",
    "client/TracyThread.hpp",
    "client/TracyArmCpuTable.hpp",
    "client/TracyProfiler.hpp",
    "client/TracyCallstack.hpp",
    "client/TracySysTime.hpp",
    "client/TracyFastVector.hpp",
};
