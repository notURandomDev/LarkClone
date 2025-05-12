//
//  RustBridge.swift
//  LarkClone
//
//  Created by Kyle Huang on 2025/5/12.
//

import Foundation

public class RustBridge {
    public static func printHello() {
        rust_sdk_print_hello()
    }
}
