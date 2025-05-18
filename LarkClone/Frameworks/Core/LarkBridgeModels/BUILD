load("@build_bazel_rules_ios//rules:framework.bzl", "apple_framework")
load("@rules_cc//cc:objc_library.bzl", "objc_library")
objc_library(
    name = "LarkBridgeModelsHeaders",
    hdrs = glob(["*.h"]),
    includes = ["."],  # 包含当前目录下的所有文件
    visibility = ["//visibility:public"],
)
apple_framework(
    name = "LarkBridgeModels",
    module_name = "LarkBridgeModels",  # optional, default to name

    # private sources
    srcs = glob([
        # "*.h",
        "*.swift",
    ]),
    # any compatible provider: CCProvider, SwiftInfo, etc
    deps = [
        "//LarkClone/Frameworks/Core/LarkSDKPB:LarkSDKPB"
    ],
    visibility = ["//visibility:public"],
)