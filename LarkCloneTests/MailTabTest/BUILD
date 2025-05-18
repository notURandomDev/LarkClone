load("@build_bazel_rules_ios//rules:framework.bzl", "apple_framework")
load("@build_bazel_rules_apple//apple:resources.bzl", "apple_resource_group")
load("@rules_cc//cc:objc_library.bzl", "objc_library")

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

apple_framework(
    name = "MailTabTest",
    module_name = "MailTabTest",  # optional, default to name
    # module_map = "Sources/Controllers/module.modulemap",  # optional, default to "module.modulemap"
    # private sources
    srcs = glob([
        "Sources/**/*.swift",
        "Sources/**/*.h",
    ]),

    # any compatible provider: CCProvider, SwiftInfo, etc
    deps = [
        "//LarkClone/Frameworks/Core/LarkSDKPB:LarkSDKPB",
        "//LarkClone/Frameworks/Core/LarkBridgeModels:LarkBridgeModels",
        "//LarkClone/Frameworks/Core/LarkSDK:LarkSDK",
        "//LarkClone/Frameworks/UI/LarkColor:LarkColorObjc",
        "//LarkClone/Frameworks/UI/LarkSearchBar:LarkSearchBar",
        "//LarkClone/Frameworks/UI/Components:Components",
        # "//LarkClone/Frameworks/UI/Components:ComponentsHeaders",
        "//LarkClone/Frameworks/UI/LarkColor:LarkColorHeaders",
        "//LarkClone/Frameworks/UI/LarkSearchBar:LarkSearchBarHeaders",
        "//RustSDK:rust_sdk",
        ":MailTabHeaders"
    ],
    platforms = {"ios": "18.4"},  
    visibility = ["//visibility:public"],
)