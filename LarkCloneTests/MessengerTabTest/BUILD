load("@build_bazel_rules_ios//rules:framework.bzl", "apple_framework")
load("@build_bazel_rules_ios//rules:test.bzl", "ios_ui_test")
load("@build_bazel_rules_ios//rules:test.bzl", "ios_unit_test")

ios_ui_test(
    name = "MessengerTabTest",
    srcs = glob([
        "**/*.swift",
    ]),
    deps = [
        "//LarkClone:LarkClone",
        "//LarkClone/Frameworks/UI/LarkChatBubble:LarkChatBubble",
    ],
    minimum_os_version = "18.0",
    test_host = "//LarkClone:LarkCloneApp",
)

