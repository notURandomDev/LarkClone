//
//  RustBridge.swift
//  LarkClone
//
//  Created by Kyle Huang on 2025/5/12.
//

import Foundation
import LarkSDKPB

// 用于保存 Swift 侧回调
final class RustCallbackStore {
    static let shared = RustCallbackStore()
    private init() {}

    // 联系人回调
    var contactsCallback: ((Result<[Lark_Contact], Error>) -> Void)?
    // 邮件回调
    var mailsCallback: ((Result<[Lark_MailItem], Error>) -> Void)?
}

// Swift 静态回调函数，供 Rust 调用（联系人）
@_cdecl("swift_contacts_callback")
func swift_contacts_callback(ptr: UnsafeMutablePointer<UInt8>?, len: UInt) {
    guard let ptr = ptr else {
        RustCallbackStore.shared.contactsCallback?(
            .failure(NSError(domain: "RustBridge", code: 1, userInfo: [NSLocalizedDescriptionKey: "Null pointer from Rust"]))
        )
        return
    }

    let data = Data(bytes: ptr, count: Int(len))
    rust_sdk_free_data(ptr)

    do {
        let contactList = try Lark_ContactList(serializedBytes: data)
        RustCallbackStore.shared.contactsCallback?(.success(contactList.contacts))
    } catch {
        RustCallbackStore.shared.contactsCallback?(.failure(error))
    }
}

// Swift 静态回调函数，供 Rust 调用（邮件）
@_cdecl("swift_mails_callback")
func swift_mails_callback(ptr: UnsafeMutablePointer<UInt8>?, len: UInt) {
    guard let ptr = ptr else {
        RustCallbackStore.shared.mailsCallback?(
            .failure(NSError(domain: "RustBridge", code: 1, userInfo: [NSLocalizedDescriptionKey: "Null pointer from Rust"]))
        )
        return
    }

    let data = Data(bytes: ptr, count: Int(len))
    rust_sdk_free_data(ptr)

    do {
        let mailList = try Lark_MailItemList(serializedBytes: data)
        RustCallbackStore.shared.mailsCallback?(.success(mailList.items))
    } catch {
        RustCallbackStore.shared.mailsCallback?(.failure(error))
    }
}

public class RustBridge {
    public static func printHello() {
        rust_sdk_print_hello()
    }

    public static func fetchContacts(
        page: Int32,
        pageSize: Int32,
        filePath: String,
        completion: @escaping (Result<[Lark_Contact], Error>) -> Void
    ) {
        // 保存联系人回调
        RustCallbackStore.shared.contactsCallback = completion

        // 调用 Rust，传入静态 Swift 回调函数指针
        filePath.withCString { cStr in
            rust_sdk_fetch_contacts_async(page, pageSize, cStr, swift_contacts_callback)
        }
    }

    public static func fetchMails(
        page: Int32,
        pageSize: Int32,
        filePath: String,
        completion: @escaping (Result<[Lark_MailItem], Error>) -> Void
    ) {
        // 保存邮件回调
        RustCallbackStore.shared.mailsCallback = completion

        // 调用 Rust，传入静态 Swift 回调函数指针
        filePath.withCString { cStr in
            rust_sdk_fetch_mails_async(page, pageSize, cStr, swift_mails_callback)
        }
    }
}
