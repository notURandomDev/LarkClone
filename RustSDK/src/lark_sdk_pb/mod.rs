pub mod contact;
pub mod mail;

use crate::lark_sdk::data::Contact as RustContact;
use crate::lark_sdk::data::MailItemBase;
use prost::Message;

// 将 Rust 代码形式的联系人数据序列化为 Protobuf
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
                avatar_name: c.avatar_name,
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

// 将 Rust 代码形式的邮件数据序列化为 Protobuf
pub fn serialize_mails(mails: Vec<MailItemBase>) -> Vec<u8> {
    let pb_mails: Vec<mail::MailItem> = mails
        .into_iter()
        .map(|m| mail::MailItem {
            id: m.id,
            sender: m.sender,
            subject: m.subject,
            preview: m.preview,
            date_string: m.date_string,
            is_read: m.is_read,
            has_attachment: m.has_attachment,
            is_official: m.is_official,
            email_count: m.email_count,
        })
        .collect();

    // 将包装成 Protobuf 顶层消息
    let mail_list = mail::MailItemList { items: pb_mails };

    // 将顶层消息存到一个缓冲区中，方便后续指针的操作
    let mut buf = Vec::new();
    mail_list.encode(&mut buf).unwrap();
    buf
}
