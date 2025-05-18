load("@build_bazel_rules_ios//rules:framework.bzl", "apple_framework")

apple_framework(
    name = "LarkChatBubble",
    module_name = "LarkChatBubble",
    srcs = glob([
        "*.swift",
    ]),
    deps = [
        "//LarkClone/Frameworks/UI/LarkColor:LarkColor",
    ],
    platforms = {"ios": "18.4"},  
    
    visibility = ["//visibility:public"],
)