load("@build_bazel_rules_ios//rules:framework.bzl", "apple_framework")

apple_framework(
    name = "LarkSDK",
    module_name = "LarkSDK",  # optional, default to name
    module_map = "module.modulemap",
    # private sources
    srcs = glob([
        "*.h",
        "*.swift",
    ]),
    # any compatible provider: CCProvider, SwiftInfo, etc
    deps = [
        "//LarkClone/Frameworks/Core/LarkSDKPB:LarkSDKPB",
        "//LarkClone/Frameworks/Core/LarkBridgeModels:LarkBridgeModels",
        "//RustSDK:RustSDKHeaders",
    ],
    visibility = ["//visibility:public"],
)