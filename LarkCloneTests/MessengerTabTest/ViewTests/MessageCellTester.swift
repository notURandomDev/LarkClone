import UIKit
import LarkChatBubble

@testable import LarkClone

class MessageCellTester {
    let cell: MessageCell
    
    init(cell: MessageCell) {
        self.cell = cell
    }
    
    // 检查已读状态视图是否隐藏
    func isReadStatusHidden() -> Bool? {
        for subview in cell.contentView.subviews {
            if let imageView = subview as? UIImageView {
                // 查找小尺寸的UIImageView，可能是已读状态图标
                let hasCorrectConstraints = imageView.constraints.contains { constraint in
                    return (constraint.firstAttribute == .width && constraint.constant == 12) ||
                           (constraint.firstAttribute == .height && constraint.constant == 12)
                }
                
                if hasCorrectConstraints {
                    return imageView.isHidden
                }
            }
        }
        return nil
    }
    
    // 检查发送者名称标签是否隐藏
    func isSenderNameHidden() -> Bool? {
        for subview in cell.contentView.subviews {
            if let label = subview as? UILabel {
                // 发送者名称标签通常是12号字体
                if label.font?.pointSize == 12 && !isTimeLabel(label) {
                    return label.isHidden
                }
            }
        }
        return nil
    }
    
    // 判断是否是时间标签
    private func isTimeLabel(_ label: UILabel) -> Bool {
        // 通常时间标签有15pt高度约束
        return label.constraints.contains { constraint in
            return constraint.firstAttribute == .height && constraint.constant == 15
        }
    }
    
    // 获取消息文本
    func getMessageText() -> String? {
        // 首先查找ChatBubbleView
        for subview in cell.contentView.subviews {
            if let bubbleView = subview as? ChatBubbleView {
                #if DEBUG
                // 使用测试辅助方法(如果可用)
                return bubbleView.testHelper_getText()
                #else
                // 如果测试辅助方法不可用，直接访问messageLabel
                return bubbleView.messageLabel.text
                #endif
            }
        }
        return nil
    }
    
    // 获取时间文本
    func getTimeText() -> String? {
        for subview in cell.contentView.subviews {
            if let label = subview as? UILabel {
                if isTimeLabel(label) {
                    return label.text
                }
            }
        }
        return nil
    }
    
    // 检查头像是否显示
    func isAvatarHidden() -> Bool? {
        for subview in cell.contentView.subviews {
            if let imageView = subview as? UIImageView {
                // 头像通常是36x36大小
                let hasCorrectSizeConstraints = imageView.constraints.contains { constraint in
                    return (constraint.firstAttribute == .width && constraint.constant == 36) ||
                           (constraint.firstAttribute == .height && constraint.constant == 36)
                }
                
                if hasCorrectSizeConstraints {
                    return imageView.isHidden
                }
            }
        }
        return nil
    }
    
    // 获取气泡类型
    func getBubbleType() -> BubbleType? {
        for subview in cell.contentView.subviews {
            if let bubbleView = subview as? ChatBubbleView {
                #if DEBUG
                return bubbleView.testHelper_getBubbleType()
                #else
                // 如果测试辅助方法不可用，通过背景色判断
                if bubbleView.backgroundColor == LarkColorStyle.ChatBubble.Sent.backgroundColor {
                    return .sent
                } else {
                    return .received
                }
                #endif
            }
        }
        return nil
    }
}
