#[derive(Clone)]
pub struct Contact {
    pub name: String,
    pub latest_msg: String,
    pub datetime: String,
    pub contact_type: String,
    pub avatar_name: String,
}

#[derive(Debug, Clone, PartialEq)]
pub struct MailItemBase {
    pub id: String,
    pub sender: String,
    pub sender_avatar: String,
    pub subject: String,
    pub preview: String,
    pub date_string: String,
    pub is_read: bool,
    pub has_attachment: bool,
    pub is_official: bool,
    pub email_count: Option<i32>,
}
