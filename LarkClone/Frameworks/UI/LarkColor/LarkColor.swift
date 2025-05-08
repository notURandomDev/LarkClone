//
//  LarkColor.swift
//  Feishu-clone
//
//  Created by 张纪龙 on 2025/4/28.
//

import UIKit

struct LarkColor {
    // 标签颜色
    struct Tag {
        // 机器人标签
        struct Bot {
            static var textColor: UIColor {
                return UIColor { traitCollection in
                    return traitCollection.userInterfaceStyle == .dark
                        ? UIColor(red: 200/255.0, green: 150/255.0, blue: 30/255.0, alpha: 1)
                        : UIColor(red: 172/255.0, green: 123/255.0, blue: 3/255.0, alpha: 1)
                }
            }
            
            static var backgroundColor: UIColor {
                return UIColor { traitCollection in
                    return traitCollection.userInterfaceStyle == .dark
                        ? UIColor(red: 60/255.0, green: 50/255.0, blue: 10/255.0, alpha: 1)
                        : UIColor(red: 253/255.0, green: 246/255.0, blue: 220/255.0, alpha: 1)
                }
            }
        }
        
        // 外部联系人标签
        struct External {
            static var textColor: UIColor {
                return UIColor { traitCollection in
                    return traitCollection.userInterfaceStyle == .dark
                        ? UIColor(red: 100/255.0, green: 140/255.0, blue: 255/255.0, alpha: 1)
                        : UIColor(red: 17/255.0, green: 72/255.0, blue: 219/255.0, alpha: 1)
                }
            }
            
            static var backgroundColor: UIColor {
                return UIColor { traitCollection in
                    return traitCollection.userInterfaceStyle == .dark
                        ? UIColor(red: 30/255.0, green: 40/255.0, blue: 80/255.0, alpha: 1)
                        : UIColor(red: 209/255.0, green: 221/255.0, blue: 253/255.0, alpha: 1)
                }
            }
        }
    }
    
    // 文本颜色
    struct Text {
        static var primary: UIColor {
            return UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark
                    ? UIColor.white
                    : UIColor.black
            }
        }
        
        static var secondary: UIColor {
            return UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark
                    ? UIColor.lightGray
                    : UIColor.systemGray
            }
        }
    }
}
