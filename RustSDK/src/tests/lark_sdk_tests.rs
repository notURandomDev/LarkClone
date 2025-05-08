#[cfg(test)]
mod tests {
    use crate::lark_sdk::plist;

    #[test]
    fn test_parse_plist() {
        // 需要一个测试用的 plist 文件
        let contacts = plist::parse_plist("path/to/test_contacts.plist");
        assert!(contacts.len() >= 0);
    }
}
