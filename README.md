# 支持多构建系统的混合技术栈（Swift、OC、Rust）仿飞书 APP 开发

## 仓库说明

该仓库的初始化是基于「Feishu-clone」仓库的代码之上进行重构的；核心的变动是项目中 Framework 的模块划分，以及更加合理的和可扩展的项目架构。

如果想要查看项目重构前的 commit，可以[点击跳转 ➡️](https://github.com/notURandomDev/Feishu-clone) 。

该仓库包含了两个主要的工程目录：

- LarkClone：使用 Swift 语言开发的 iOS App 工程
- RustSDK：使用 Rust 语言开发的 SDK 工程

## 项目概要介绍

该项目是字节跳动-飞书客户端（iOS）技术训练营的课题。

### 课题名称

开发一个简易的仿飞书 App，包含「消息」和「邮箱」两个 Tab。

### 课题要求

- UI 部分使用 Swift、OC 开发
- 底层数据服务使用 Rust 开发
- Swift、OC 与 Rust 使用 protobuf 通信
- 支持 xcodebuild、bazel 两套构建系统

### 课题目的

飞书技术训练营希望能够通过这个课题，使参与开发的同学了解：

1. 基础 iOS UI 开发，使用 Swift、OC，开发一个多 Tab 应用，包含下面一些 UI 开发技术
   1. UIImage、UIImageView、UIButton、UILabel、UIViewController 等基础控件
   2. 使用 autolayout 进行布局
   3. 简单的 UI 转场动画
2. 基础移动端 SDK 开发，使用 Rust 语言，开发一套数据解析 SDK
   1. SDK 与 UI 部分，使用 protobuf 进行通信
3. 了解构建系统，了解 Xcodebuild、Bazel 的作用，各自的优势
   1. 通过命令行，调用 xcodebuild 命令，进行 App 开发
   2. 将基于 Xcodebuild 构建系统的 App 转成 Bazel 构建系统

### 竞品参考

飞书

## LarkClone

该目录下包含了所有 iOS App 开发所涉及到的代码文件。

```text
main.swift
---------
MessengerTab.framework  MailTab.framework （Swift、OC）
---------
LarkColor.framework   LarkLoadMore.framework  LarkAvatar.framework  LarkNavigation.framework
---------
LarkSDKPB.framework
---------
LarkSDK.framework
```

### 项目结构

AppDelegate.swift 和 SceneDelegate.swift 暂时放在了 LarkClone 的根目录下。

`Framework/` 目录下分成了三个子目录，分别为：

- Core：核心基础框架，提供网络、数据模型、工具类等基础能力
  - LarkFoundation、LarkSDK、LarkSDKPB
- Tabs：独立页面模块
  - MessengerTab、MailTab
- UI：通用 UI 组件
  - LarkColor、LarkLoadMore、LarkAvatar、LarkNavigation

### Tab 框架结构

Tab 框架（framework）的目录下主要有三个子目录：

- Resources：资源文件
- Sources：主要代码文件
- Tests：测试相关文件

其中，`Source/` 目录结构遵循 MVC（Model-View-Controller）原则进行解耦：

- Models：框架中使用到的结构体
- Views：与视图相关的文件（如 Cell、ViewController）
- Controllers：用于操作数据（如 DataManager）

除此之外，还有一些工具类型的文件存于以下目录：

- Scripts：脚本文件
- Extensions：协议的拓展

## RustSDK

### 工程概述

该目录下的工程使用 Rust 语言开发，用于模拟飞书应用中处理网络请求的 SDK ；工程代码的主要功能是：

- 解析 plist 的 mock 数据，生成相应的 Rust 数据体
- 将 Rust 数据体编码成 Protobuf Buffers（Protobuf），写入内存
- 通过 C 语言的 ABI（Application Binary Interface） 能力，暴露 FFI（Foreign Function Interface）接口，供 Swift 侧调用

其中，该工程需要编译成静态库，放置到 Swift 侧的工程中，以进行 SDK 的调用。

### 项目结构

`lark_sdk/` 目录下的代码实现了将 plist 数据转换成 Rust 数据体，以及异步函数的实现。

- async_handler.rs：定义了异步函数相关逻辑，供 Swift 侧调用
- data.rs：定义了结构体
- plist.rs：将 plist 数据转换成 Rust 数据体

`lark_sdk_pb/` 目录下的代码主要定义了 .proto 以及 Rust 数据体序列化的实现。

- contact.proto：联系人实体的 .proto 文件
- contact.rs：在 .proto 文件之上，由 Rust 自动生成的具有序列化和反序列化能力的 Rust 结构体
- mod.rs：将 Rust 数据体编码成 Protobuf 数据的实现逻辑

最后，`src/` 根目录下的 lib.rs 文件将 Rust 代码封装成高层次的接口进行暴露，供 Swift 侧通过静态库调用。
