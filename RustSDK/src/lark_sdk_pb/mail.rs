#[derive(Clone, PartialEq, ::prost::Message)]
pub struct MailItem {
    /// 唯一标识符 (对应 NSString *id)
    #[prost(string, tag = "1")]
    pub id: ::prost::alloc::string::String,
    /// 发件人 (对应 NSString *sender)
    #[prost(string, tag = "2")]
    pub sender: ::prost::alloc::string::String,
    /// 邮件主题 (对应 NSString *subject)
    #[prost(string, tag = "3")]
    pub subject: ::prost::alloc::string::String,
    /// 预览文本 (对应 NSString *preview)
    #[prost(string, tag = "4")]
    pub preview: ::prost::alloc::string::String,
    /// 日期字符串 (对应 NSString *dateString -> NSDate *date)
    #[prost(string, tag = "5")]
    pub date_string: ::prost::alloc::string::String,
    /// 是否已读 (对应 BOOL isRead)
    #[prost(bool, tag = "6")]
    pub is_read: bool,
    /// 是否有附件 (对应 BOOL hasAttachment)
    #[prost(bool, tag = "7")]
    pub has_attachment: bool,
    /// 是否官方邮件 (对应 BOOL isOfficial)
    #[prost(bool, tag = "8")]
    pub is_official: bool,
    /// 会话邮件数量 (对应 nullable NSNumber *emailCount)
    /// 使用 optional 表示可空
    #[prost(int32, optional, tag = "9")]
    pub email_count: ::core::option::Option<i32>,
}
/// 邮件列表响应
#[derive(Clone, PartialEq, ::prost::Message)]
pub struct MailItemList {
    #[prost(message, repeated, tag = "1")]
    pub items: ::prost::alloc::vec::Vec<MailItem>,
}
