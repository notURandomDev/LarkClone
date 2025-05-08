fn main() {
    let proto_path = "src/lark_sdk_pb/contact.proto";
    let out_dir = "src/lark_sdk_pb"; // 指定生成到模块目录

    // 检查 proto 文件是否存在
    if !std::path::Path::new(proto_path).exists() {
        eprintln!("Error: Protobuf file not found at {}", proto_path);
        std::process::exit(1);
    }

    // 确保输出目录存在
    std::fs::create_dir_all(out_dir).unwrap();

    // 编译并指定输出目录
    prost_build::Config::new()
        .out_dir(out_dir) // 关键：生成到 lark_sdk_pb/ 目录
        .compile_protos(&[proto_path], &["src/lark_sdk_pb/"]) // 搜索路径为 proto 所在目录
        .unwrap_or_else(|e| {
            eprintln!("Failed to compile protos: {}", e);
            std::process::exit(1);
        });
}
