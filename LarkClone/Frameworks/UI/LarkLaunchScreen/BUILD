load("@build_bazel_rules_ios//rules:framework.bzl", "apple_framework")
load("@build_bazel_rules_apple//apple:resources.bzl", "apple_resource_group")

apple_resource_group(
    name = "LarkLaunchScreenResources",
    resources = glob([
        "Assets.xcassets/**",
    ]),
    visibility = ["//visibility:public"],
)
apple_framework(
    name = "LarkLaunchScreen",
    module_name = "LarkLaunchScreen",
    srcs = glob([
        "*.swift",
    ]),
    platforms = {"ios": "18.4"},  
    visibility = ["//visibility:public"],
)