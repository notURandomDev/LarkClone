mod lark_sdk;
mod lark_sdk_pb;

use lark_sdk::async_handler;
use std::ffi::CStr;
use std::os::raw::c_char;

// 用于测试 FFI 调用的测试函数
#[unsafe(no_mangle)]
pub extern "C" fn rust_sdk_print_hello() {
    println!("Hello from Rust!");
}

// 获取联系人的回调函数
pub type FetchContactsCallback = unsafe extern "C" fn(data: *mut u8, len: usize);

// Swift侧调用的获取联系人异步函数(Rust)
#[unsafe(no_mangle)]
pub extern "C" fn rust_sdk_fetch_contacts_async(
    page: i32,
    page_size: i32,
    file_path: *const c_char,
    callback: FetchContactsCallback,
) {
    let file_path = unsafe {
        let c_str = CStr::from_ptr(file_path);
        c_str.to_str().unwrap_or_default().to_string()
    };
    async_handler::fetch_contacts_async(page, page_size, file_path, callback);
}

// 获取邮件的回调函数
pub type FetchMailsCallback = unsafe extern "C" fn(*mut u8, usize);

// Swift侧调用的获取邮件异步函数(Rust)
#[unsafe(no_mangle)]
pub extern "C" fn rust_sdk_fetch_mails_async(
    page: i32,
    page_size: i32,
    file_path: *const c_char,
    callback: FetchMailsCallback,
) {
    let file_path = unsafe {
        let c_str = CStr::from_ptr(file_path);
        c_str.to_str().unwrap_or_default().to_string()
    };
    async_handler::fetch_mails_async(page, page_size, file_path, callback);
}

// Swift侧调用的释放 Protobuf 内存函数
#[unsafe(no_mangle)]
pub extern "C" fn rust_sdk_free_data(ptr: *mut u8) {
    if !ptr.is_null() {
        unsafe {
            libc::free(ptr as *mut libc::c_void);
        }
    }
}
