load("@build_bazel_rules_ios//rules:framework.bzl", "apple_framework")

objc_library(
    name = "LarkSearchBarHeaders",
    hdrs = glob(["*.h"]),
    includes = ["."],  # 包含当前目录下的所有文件
    visibility = ["//visibility:public"],
)

apple_framework(
    name = "LarkSearchBar",
    module_name = "LarkSearchBar",
    srcs = glob([
        "*.m",
        # "*.h",
    ]),
    deps = [":LarkSearchBarHeaders"],  # 可能依赖其他模块
    platforms = {"ios": "18.0"},  
    
    visibility = ["//visibility:public"],
)
