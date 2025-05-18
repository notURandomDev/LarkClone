load("@build_bazel_rules_ios//rules:framework.bzl", "apple_framework")
load("@rules_cc//cc:objc_library.bzl", "objc_library")

objc_library(
    name = "ComponentsHeaders",
    hdrs = glob(["*.h"]),
    includes = ["."],  # 包含当前目录下的所有文件
    visibility = ["//visibility:public"],
)

apple_framework(
    name = "Components",
    module_name = "Components",
    srcs = glob([
        "*.m",
        "*.h",
    ]),
    # includes = ["."],  # 包含当前目录下的所有文件
    # deps = [":ComponentsHeaders"],  # 可能依赖其他模块
    platforms = {"ios": "18.0"},  
    
    visibility = ["//visibility:public"],
)
