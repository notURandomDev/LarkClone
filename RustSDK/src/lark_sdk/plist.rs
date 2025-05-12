use crate::lark_sdk::data::Contact;
use plist::Value;

// 将 plist 中的数据解析成 Rust 代码
pub fn parse_plist(file_path: &str) -> Vec<Contact> {
    // 解析 plist 中的数据，value 的数据类型取决于 plist 根节点的数据类型（array/dict）
    let value = Value::from_file(file_path).unwrap_or_else(|_| Value::Array(vec![]));
    // 解包 value 失败的 fallback 空数组，单独写一行是为了增强可读性
    let empty_vec = vec![];
    // 对 value 进行解包，这里要求 plist 的根节点数据必须是 array 数组类型 (as_array)
    let array = value.as_array().unwrap_or(&empty_vec);
    // 遍历 plist 的节点数据，并且过滤 none 值
    array
        .iter()
        .filter_map(|item| {
            let dict = item.as_dictionary()?;
            let name = dict.get("name")?.as_string()?.to_string();
            let latest_msg = dict.get("latestMsg")?.as_string()?.to_string();
            let datetime = dict.get("datetime")?.as_string()?.to_string();
            let contact_type = dict.get("type")?.as_string()?.to_string();
            let avatar_name = dict.get("avatarName")?.as_string()?.to_string();
            Some(Contact {
                name,
                latest_msg,
                datetime,
                contact_type,
                avatar_name,
            })
        })
        .collect()
}
