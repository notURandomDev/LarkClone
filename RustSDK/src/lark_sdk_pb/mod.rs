pub mod contact;

use crate::lark_sdk::data::Contact as RustContact;
use prost::Message;

// 将 Rust 代码形式的数据序列化为 Protobuf
pub fn serialize_contacts(contacts: Vec<RustContact>) -> Vec<u8> {
    let pb_contacts: Vec<contact::Contact> = contacts
        .into_iter()
        .map(|c| {
            let name = c.name;
            contact::Contact {
                name,
                latest_msg: c.latest_msg,
                datetime: c.datetime,
                contact_type: c.contact_type,
            }
        })
        .collect();

    // 将包装成 Protobuf 顶层消息
    let contact_list = contact::ContactList {
        contacts: pb_contacts,
    };

    // 将顶层消息存到一个缓冲区中，方便后续指针的操作
    let mut buf = Vec::new();
    contact_list.encode(&mut buf).unwrap();
    buf
}
