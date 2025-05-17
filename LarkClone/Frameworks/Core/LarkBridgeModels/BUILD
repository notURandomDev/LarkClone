load("@rules_ios//rules:framework.bzl", "apple_framework")


apple_framework(
    name = "LarkBridgeModels",
    module_name = "LarkBridgeModels",  # optional, default to name
    module_map = "",  # optional... objc only
                      # we'll add the swift stuff under the hood

    # private sources
    srcs = glob([
        "*.swift",
        "*.m",
        "*.mm",
        "*.hh",
        "*.h",
    ]),
    # public headers
    hdrs = glob([
        "*.h",
        "*.hh",
    ]),

    # any compatible provider: CCProvider, SwiftInfo, etc
    deps = [],
)