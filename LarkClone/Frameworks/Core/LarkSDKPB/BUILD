load("@build_bazel_rules_ios//rules:framework.bzl", "apple_framework")

apple_framework(
    name = "LarkSDKPB",
    module_name = "LarkSDKPB",  # optional, default to name

    # private sources
    srcs = glob([
        "*.swift",
    ]),

    # any compatible provider: CCProvider, SwiftInfo, etc
    deps = [
        "//RustSDK:proto_swift"
    ],
    platforms = {"ios": "18.0"}, 
    visibility = ["//visibility:public"],
)