load("@build_bazel_rules_ios//rules:framework.bzl", "apple_framework")


apple_framework(
    name = "LarkAvatar",
    module_name = "LarkAvatar",
    srcs = glob([
        "*.swift",
    ]),
    platforms = {"ios": "18.0"},  
    
    visibility = ["//visibility:public"],
)