use crate::lark_sdk::data::Contact;
use crate::lark_sdk::data::MailItemBase;
use plist::Value;

// 将 plist 中的数据解析成 Rust 代码
pub fn parse_contacts_plist(file_path: &str) -> Vec<Contact> {
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

pub fn parse_mails_plist(file_path: &str) -> Vec<MailItemBase> {
    // 解析 plist 中的数据，value 的数据类型取决于 plist 根节点的数据类型（array/dict）
    let value = Value::from_file(file_path).unwrap_or_else(|_| Value::Array(vec![]));

    // 打印完整节点数据
    // println!("Plist 根节点:");
    // debug_plist_value(&value, 1);

    // 解包 value 失败的 fallback 空数组，单独写一行是为了增强可读性
    let empty_vec = vec![];
    // 对 value 进行解包，这里要求 plist 的根节点数据必须是 array 数组类型 (as_array)
    let array = value.as_array().unwrap_or(&empty_vec);
    // 遍历 plist 的节点数据，并且过滤 none 值
    array
        .iter()
        .filter_map(|item| {
            let dict = item.as_dictionary()?;
            let id = dict.get("id")?.as_string()?.to_string();
            let sender = dict.get("sender")?.as_string()?.to_string();
            let subject = dict.get("subject")?.as_string()?.to_string();
            let preview = dict.get("preview")?.as_string()?.to_string();
            let date_string = dict.get("date")?.as_string()?.to_string();
            let is_read = dict.get("isRead")?.as_boolean()?;
            let has_attachment = dict.get("hasAttachment")?.as_boolean()?;
            let is_official = dict.get("isOfficial")?.as_boolean()?;
            let email_count = dict
                .get("emailCount")
                .and_then(|v| v.as_signed_integer())
                .map(|v| v as i32);

            Some(MailItemBase {
                id,
                sender,
                subject,
                preview,
                date_string,
                is_read,
                has_attachment,
                is_official,
                email_count,
            })
        })
        .collect()
}

// 调试函数：打印 Value 的内容
fn debug_plist_value(value: &Value, indent: usize) {
    let indent_str = "  ".repeat(indent);
    match value {
        Value::Array(arr) => {
            println!("{}Array (length: {}):", indent_str, arr.len());
            for (i, item) in arr.iter().enumerate() {
                println!("{}[{}]:", indent_str, i);
                debug_plist_value(item, indent + 1);
            }
        }
        Value::Dictionary(dict) => {
            println!("{}Dictionary (keys: {}):", indent_str, dict.len());
            for (key, val) in dict {
                println!("{}{}:", indent_str, key);
                debug_plist_value(val, indent + 1);
            }
        }
        Value::String(s) => println!("{}String: {}", indent_str, s),
        Value::Boolean(b) => println!("{}Boolean: {}", indent_str, b),
        Value::Real(r) => println!("{}Real: {}", indent_str, r),
        _ => println!("{}Other: {:?}", indent_str, value),
    }
}
