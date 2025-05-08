use crate::FetchContactsCallback;
use crate::lark_sdk::plist;
use crate::lark_sdk::utils;
use crate::lark_sdk_pb;
use std::thread;

// 获取联系人的异步函数
pub fn fetch_contacts_async(
    page: i32,                       // 页码
    page_size: i32,                  // 分页大小
    file_path: String,               // plist的文件路径
    callback: FetchContactsCallback, // 回调函数
) {
    // 创建一个新线程执行异步操作
    thread::spawn(move || {
        // 解析plist文件，获取所有联系人 (XML->Rust)
        let all_contacts = plist::parse_plist(&file_path);

        // 调用记录日志的工具函数，显示已加载联系人的数量
        utils::log(&format!(
            "Loaded {} contacts from plist",
            all_contacts.len()
        ));

        // 计算当前页面中，首个联系人的位置
        let start = (page * page_size) as usize;

        // 获取当前分页范围内的所有联系人数据
        let page_contacts = all_contacts
            .into_iter() // 转换为迭代器
            .skip(start) // 跳过当前分页之前的元素
            .take(page_size as usize) // 取指定数量的元素
            .collect::<Vec<_>>(); // 收集为Vec数组

        // 调用序列化函数，将联系人数据编码成 Protobuf 二进制数据
        let pb_data = lark_sdk_pb::serialize_contacts(page_contacts);
        let len = pb_data.len();

        // 当 pb_data 离开作用域之后，Rust会自动释放内存
        // 为了使外部代码能够有效访问到 Protobuf 二进制数据，手动分配内存
        let ptr = unsafe {
            let ptr = libc::malloc(len) as *mut u8;
            std::ptr::copy_nonoverlapping(pb_data.as_ptr(), ptr, len);
            ptr
        };

        // 将指针作为callback的参数传入，使Swift侧能够根据该指针访问到 Protobuf 编码后的联系人数据
        unsafe {
            callback(ptr, len);
        }
    });
}
