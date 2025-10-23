const std = @import("std");
const rlz = @import("raylib_zig");

pub fn build(b: *std.Build) void {
    // Options
    const server = b.option(bool, "server", "Whether this is the server executable.") orelse false;
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Shared

    const shared_module = b.createModule(.{
        .root_source_file = b.path("src/shared/lib.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Engine

    const engine_module = b.createModule(.{
        .root_source_file = b.path("src/engine/lib.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Client

    const client_module = b.createModule(.{
        .root_source_file = b.path("src/client/main.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "shared", .module = shared_module },
            .{ .name = "engine", .module = engine_module },
        },
    });

    // Server

    const server_module = b.createModule(.{
        .root_source_file = b.path("src/server/main.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "shared", .module = shared_module },
            .{ .name = "engine", .module = engine_module },
        },
    });

    // EXE

    const exe = b.addExecutable(.{
        .name = "fear_city",
        .root_module = if (server) server_module else client_module,
    });
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
    });

    const run_exe_tests = b.addRunArtifact(exe_tests);
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_exe_tests.step);

    // PACKAGES

    // Shared Packages

    // ECS

    const zig_ecs = b.dependency("entt", .{
        .target = target,
        .optimize = optimize,
    });
    const ecs = zig_ecs.module("zig-ecs");
    exe.root_module.addImport("ecs", ecs);
    shared_module.addImport("ecs", ecs);

    // Websocket

    const zig_ws = b.dependency("websocket", .{
        .target = target,
        .optimize = optimize,
    });
    const ws = zig_ws.module("websocket");
    exe.root_module.addImport("websocket", ws);
    shared_module.addImport("websocket", ws);

    // Client Packages

    // Raylib

    const raylib_dep = b.dependency("raylib_zig", .{
        .target = target,
        .optimize = optimize,
    });

    const raylib = raylib_dep.module("raylib"); // main raylib module
    const raygui = raylib_dep.module("raygui"); // raygui module
    const raylib_artifact = raylib_dep.artifact("raylib"); // raylib C library

    exe.linkLibrary(raylib_artifact);
    client_module.addImport("raylib", raylib);
    shared_module.addImport("raylib", raylib);
    engine_module.addImport("raylib", raylib);

    client_module.addImport("raygui", raygui);
    engine_module.addImport("raygui", raygui);
    // WASM build
    if (target.query.os_tag == .emscripten) {
        const emsdk = rlz.emsdk;
        const wasm = b.addLibrary(.{
            .name = "fear_city",
            .root_module = client_module,
        });

        const install_dir: std.Build.InstallDir = .{ .custom = "web" };
        const emcc_flags = emsdk.emccDefaultFlags(b.allocator, .{ .optimize = optimize });
        const emcc_settings = emsdk.emccDefaultSettings(b.allocator, .{ .optimize = optimize });

        const emcc_step = emsdk.emccStep(b, raylib_artifact, wasm, .{
            .optimize = optimize,
            .flags = emcc_flags,
            .settings = emcc_settings,
            .install_dir = install_dir,
        });
        b.getInstallStep().dependOn(emcc_step);

        const html_filename = std.fmt.allocPrint(b.allocator, "{s}.html", .{wasm.name}) catch "mem_error.html";
        const emrun_step = emsdk.emrunStep(
            b,
            b.getInstallPath(install_dir, html_filename),
            &.{},
        );

        emrun_step.dependOn(emcc_step);
        run_step.dependOn(emrun_step);
    }
}
