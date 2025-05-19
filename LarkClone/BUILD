package(default_visibility = ["//visibility:public"])

load("@build_bazel_rules_ios//rules:framework.bzl", "apple_framework")
load("@build_bazel_rules_apple//apple:resources.bzl", "apple_resource_group")
load("@build_bazel_rules_apple//apple:ios.bzl", "ios_application")

# ///////////////////////////////////////////////////////////////////////////////////
# ///////////////////////////////////////////////////////////////////////////////////
# ///////////////////////////////////////////////////////////////////////////////////
# ///////////////////////////////////////////////////////////////////////////////////
# MailTab
apple_resource_group(
    name = "MailTabResources",
    resources = glob([
        "Frameworks/Tabs/MailTab/Resources/**",
    ]),
    visibility = ["//visibility:public"],
)


apple_framework(
    name = "MailTab",
    module_name = "MailTab",  # optional, default to name
    # module_map = "Sources/Controllers/module.modulemap",  # optional, default to "module.modulemap"
    # private sources
    srcs = glob([
        "Frameworks/Tabs/MailTab/Sources/**/*.m",
        "Frameworks/Tabs/MailTab/Sources/**/*.h",
    ]),

    # any compatible provider: CCProvider, SwiftInfo, etc
    deps = [
        "//LarkClone/Frameworks/Core/LarkSDKPB:LarkSDKPB",
        "//LarkClone/Frameworks/Core/LarkBridgeModels:LarkBridgeModels",
        "//LarkClone/Frameworks/Core/LarkSDK:LarkSDK",
        "//LarkClone/Frameworks/UI/LarkColor:LarkColorObjc",
        "//LarkClone/Frameworks/UI/LarkSearchBar:LarkSearchBar",
        "//LarkClone/Frameworks/UI/Components:Components",
        "//LarkClone/Frameworks/UI/Components:ComponentsHeaders",
        "//LarkClone/Frameworks/UI/LarkColor:LarkColorHeaders",
        "//LarkClone/Frameworks/UI/LarkSearchBar:LarkSearchBarHeaders",
        "//RustSDK:rust_sdk",
        ":MailTabHeaders"
    ],
    platforms = {"ios": "18.0"},  
    visibility = ["//visibility:public"],
)



# ///////////////////////////////////////////////////////////////////////////////////
# ///////////////////////////////////////////////////////////////////////////////////
# ///////////////////////////////////////////////////////////////////////////////////
# ///////////////////////////////////////////////////////////////////////////////////
# MessengerTab
apple_resource_group(
    name = "MessengerTabResources",
    resources = glob([
        "Frameworks/Tabs/MessengerTab/Resources/**",
    ]),
)

apple_framework(
    name = "MessengerTab",
    module_name = "MessengerTab",  # optional, default to name

    # private sources
    srcs = glob([
        "Frameworks/Tabs/MessengerTab/Sources/Controllers/*.swift",
        "Frameworks/Tabs/MessengerTab/Sources/Extensions/*.swift",
        "Frameworks/Tabs/MessengerTab/Sources/Models/*.swift",
        "Frameworks/Tabs/MessengerTab/Sources/Views/*.swift",
    ]),

    # any compatible provider: CCProvider, SwiftInfo, etc
    deps = [
        "//LarkClone/Frameworks/Core/LarkSDK:LarkSDK",
        "//LarkClone/Frameworks/Core/LarkSDKPB:LarkSDKPB",
        "//LarkClone/Frameworks/UI/LarkColor:LarkColor",
        "//LarkClone/Frameworks/UI/LarkAvatar:LarkAvatar",
        "//LarkClone/Frameworks/UI/LarkChatBubble:LarkChatBubble",
    ],
    platforms = {"ios": "18.0"},  
    visibility = ["//visibility:public"],
)



# ///////////////////////////////////////////////////////////////////////////////////
# ///////////////////////////////////////////////////////////////////////////////////
# ///////////////////////////////////////////////////////////////////////////////////
# ///////////////////////////////////////////////////////////////////////////////////
# Apps


apple_resource_group(
    name = "LarkCloneResources",
    resources = glob([
        "Assets.xcassets/**",
        "Frameworks/Tabs/MessengerTab/Resources/**",
        "Frameworks/Tabs/MailTab/Resources/**",
    ])+[
        # ":MailTabResources",
        # ":MessengerTabResources",
        "//LarkClone/Frameworks/UI/LarkLaunchScreen:LarkLaunchScreenResources",],
    visibility = ["//visibility:public"],
)


apple_framework(
    name = "LarkClone",
    srcs = glob([
        "**/*.swift",
        "**/*.h",
        "**/*.m",
    ], exclude=["**/Scripts/**"]),
    deps = [
        "//LarkClone/Frameworks/Core/LarkBridgeModels:LarkBridgeModels",
        # "//LarkClone/Frameworks/Core/LarkBridgeModels:LarkBridgeModelsHeaders",
        "//LarkClone/Frameworks/Core/LarkSDKPB:LarkSDKPB",
        "//LarkClone/Frameworks/Core/LarkSDK:LarkSDK",
        # "//LarkClone/Frameworks/Tabs/MessengerTab/Sources/Scripts",
        # "//LarkClone/Frameworks/Tabs/MailTab:MailTab",
        # "//LarkClone/Frameworks/Tabs/MailTab:MailTabHeaders",
        "//LarkClone/Frameworks/UI/LarkLaunchScreen:LarkLaunchScreen", # Assuming ComponentsLib is a Swift library
        "//LarkClone/Frameworks/UI/LarkColor:LarkColor", # Assuming LarkColor is a Swift library
        "//LarkClone/Frameworks/UI/LarkAvatar:LarkAvatar", # Assuming LarkAvatar is a Swift library
        
        "//LarkClone/Frameworks/UI/LarkColor:LarkColorObjc",
        "//LarkClone/Frameworks/UI/LarkSearchBar:LarkSearchBar",
        "//LarkClone/Frameworks/UI/LarkChatBubble:LarkChatBubble",
        "//LarkClone/Frameworks/UI/Components:Components",
        "//LarkClone/Frameworks/UI/Components:ComponentsHeaders",
        "//LarkClone/Frameworks/UI/LarkColor:LarkColorHeaders",
        "//LarkClone/Frameworks/UI/LarkSearchBar:LarkSearchBarHeaders",
        "//RustSDK:rust_sdk",

        "//LarkCloneTests/MailTabTest:MailTabTestHeaders"
    ],
    platforms = {"ios": "18.0"},  
    visibility = ["//visibility:public"],
)
# 3. 定义 iOS 应用目标
ios_application(
    name = "LarkCloneApp", # Bazel 内部对此应用目标的命名
    bundle_id = "teamNH.LarkClone",
    families = [
        "iphone",
        "ipad",
    ],
    infoplists = ["Info.bazel.plist"],
    minimum_os_version = "18.0",
    deps = [
        ":LarkClone",
    ],
    resources = [
        ":LarkCloneResources",
    ],
    visibility = ["//visibility:public"],
)