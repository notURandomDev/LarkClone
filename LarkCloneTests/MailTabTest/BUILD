load("@build_bazel_rules_ios//rules:framework.bzl", "apple_framework")
load("@rules_cc//cc:objc_library.bzl", "objc_library")
load("@build_bazel_rules_ios//rules:test.bzl", "ios_ui_test")
objc_library(
    name = "MailTabTestHeaders",
    hdrs = glob([
        "**/*.h",
    ]),
    includes = [".","Extensions"],
    deps = [
        "//LarkClone/Frameworks/UI/LarkSearchBar:LarkSearchBarHeaders",
    ],
    visibility = ["//visibility:public"],
)

ios_ui_test(
    name = "MailTabTest",
    srcs = glob([
        "**/*.swift",
        "**/*.h",
    ]),
    deps = [
        "//LarkClone:LarkClone",
    ],
    minimum_os_version = "18.0",
    test_host = "//LarkClone:LarkCloneApp",
)

