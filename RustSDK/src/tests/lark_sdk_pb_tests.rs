#[cfg(test)]
mod tests {
    use crate::lark_sdk::data::Contact;
    use crate::lark_sdk_pb;

    #[test]
    fn test_serialize_contacts() {
        let contacts = vec![Contact {
            name: "Alice".to_string(),
            latest_msg: "Hello".to_string(),
            datetime: "2025-04-29".to_string(),
            contact_type: "USER".to_string(),
        }];
        let pb_data = lark_sdk_pb::serialize_contacts(contacts);
        assert!(!pb_data.is_empty());
    }
}
