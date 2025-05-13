//
//  RustBridgeSymbolRetainer.swift
//  LarkClone
//
//  Created by Kyle Huang on 2025/5/13.
//

import Foundation

@objc public class RustBridgeSymbolRetainer: NSObject {
    @objc public static func retainSymbol() {
        _ = RustBridge.self
    }
}
