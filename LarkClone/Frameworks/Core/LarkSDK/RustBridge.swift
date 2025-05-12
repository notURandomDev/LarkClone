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

    var currentCallback: ((Result<[Lark_Contact], Error>) -> Void)?
}

// Swift 静态回调函数，供 Rust 调用
@_cdecl("swift_contacts_callback")
func swift_contacts_callback(ptr: UnsafeMutablePointer<UInt8>?, len: UInt) {
    guard let ptr = ptr else {
        RustCallbackStore.shared.currentCallback?(
            .failure(NSError(domain: "RustBridge", code: 1, userInfo: [NSLocalizedDescriptionKey: "Null pointer from Rust"]))
        )
        return
    }

    let data = Data(bytes: ptr, count: Int(len))
    rust_sdk_free_data(ptr)

    do {
        let contactList = try Lark_ContactList(serializedBytes: data)
        RustCallbackStore.shared.currentCallback?(.success(contactList.contacts))
    } catch {
        RustCallbackStore.shared.currentCallback?(.failure(error))
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
        // 保存 Swift 回调
        RustCallbackStore.shared.currentCallback = completion

        // 调用 Rust，传入静态 Swift 回调函数指针
        filePath.withCString { cStr in
            rust_sdk_fetch_contacts_async(page, pageSize, cStr, swift_contacts_callback)
        }
    }
}
