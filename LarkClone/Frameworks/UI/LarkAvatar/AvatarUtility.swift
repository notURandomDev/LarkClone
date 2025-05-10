//
//  AvatarUtility.swift
//  LarkClone
//
//  Created by Kyle Huang on 2025/5/10.
//

import UIKit

// 这里使用枚举是为了避免实例化，类似命名空间
public enum AvatarUtility {
    // size：支持不同尺寸的占位头像
    public static func createPlaceholderAvatar(size: CGSize = CGSize(width: 40, height: 40)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            UIColor.systemGray4.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }
}
