#[derive(Clone, PartialEq, prost::Message)]
pub struct Contact {
    #[prost(string, tag = "1")]
    pub name: prost::alloc::string::String,
    #[prost(string, tag = "2")]
    pub latest_msg: prost::alloc::string::String,
    #[prost(string, tag = "3")]
    pub datetime: prost::alloc::string::String,
    #[prost(string, tag = "4")]
    pub contact_type: prost::alloc::string::String,
    #[prost(string, tag = "5")]
    pub avatar_name: prost::alloc::string::String,
}

#[derive(Clone, PartialEq, prost::Message)]
pub struct ContactList {
    #[prost(message, repeated, tag = "1")]
    pub contacts: prost::alloc::vec::Vec<Contact>,
}
