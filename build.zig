const std = @import("std");

pub fn build(b: *std.Build) void {
    // Options
    const server = b.option(bool, "server", "Whether this is the server executable.") orelse false;

    if (server) {
        build_server(b);
    } else {
        build_client(b);
    }
}

fn build_client(b: *std.Build) void {
    const rlz = @import("raylib_zig");

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const client_module = b.createModule(.{
        .root_source_file = b.path("src/client/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe, const run_step = build_exe(b, client_module);

    build_shared(b, target, optimize, &.{client_module});

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
    client_module.addImport("raygui", raygui);

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

fn build_server(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const server_module = b.createModule(.{
        .root_source_file = b.path("src/server/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    _ = build_exe(b, server_module);

    build_shared(b, target, optimize, &.{server_module});
}

fn build_exe(b: *std.Build, mod: *std.Build.Module) struct { *std.Build.Step.Compile, *std.Build.Step } {
    const exe = b.addExecutable(.{
        .name = "fear_city",
        .root_module = mod,
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

    return .{ exe, run_step };
}

fn build_shared(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    modules: []const *std.Build.Module,
) void {
    // Engine
    const engine = b.createModule(.{
        .root_source_file = b.path("src/engine/lib.zig"),
        .target = target,
        .optimize = optimize,
    });
    for (modules) |module| {
        module.addImport("engine", engine);
    }

    // ECS
    const zig_ecs = b.dependency("entt", .{
        .target = target,
        .optimize = optimize,
    });
    const ecs = zig_ecs.module("zig-ecs");
    for (modules) |module| {
        module.addImport("ecs", ecs);
    }
}
