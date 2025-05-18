//
//  RustBridge.swift
//  LarkClone
//
//  Created by Kyle Huang on 2025/5/12.
//

import Foundation
import LarkSDKPB
import LarkBridgeModels
// import LarkSDK


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
        let contactList = try Lark_ContactList(serializedData: data)
        RustCallbackStore.shared.contactsCallback?(.success(contactList.contacts))
    } catch {
        RustCallbackStore.shared.contactsCallback?(.failure(error))
    }
}

// Swift 静态回调函数，供 Rust 调用（邮件）
@_cdecl("swift_mails_callback")
func swift_mails_callback(ptr: UnsafeMutablePointer<UInt8>?, len: UInt) {
    print("Swift: 收到回调, ptr: \(String(describing: ptr)), len: \(len)")
    guard let ptr = ptr, len > 0 else {
        print("Swift: 空数据，触发失败回调")
        RustCallbackStore.shared.mailsCallback?(.failure(NSError(domain: "Rust", code: -1, userInfo: [NSLocalizedDescriptionKey: "Empty data"])))
        return
    }
    
    let data = Data(bytes: ptr, count: Int(len))
    print("Swift: 创建 Data, 长度: \(data.count)")
    
    do {
        let mailList = try Lark_MailItemList(serializedData: data)
        print("Swift: 反序列化 \(mailList.items.count) 封邮件")
        RustCallbackStore.shared.mailsCallback?(.success(mailList.items))
    } catch {
        print("Swift: Protobuf 反序列化失败: \(error)")
        RustCallbackStore.shared.mailsCallback?(.failure(error))
    }
    print("Swift: 释放内存")
    free(ptr)
}

@objc public class RustBridge: NSObject {
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
    
    @objc public static func fetchMailItems(
        page: Int32,
        pageSize: Int32,
        filePath: String,
        completion: @escaping ([ObjCMailItem]?, NSError?) -> Void
    ) {
        fetchMails(page: page, pageSize: pageSize, filePath: filePath) { result in
            switch result {
            case .success(let items):
                let bridged = items.map { ObjCMailItem(from: $0) }
                completion(bridged, nil)
            case .failure(let error):
                completion(nil, error as NSError)
            }
        }
    }
}
