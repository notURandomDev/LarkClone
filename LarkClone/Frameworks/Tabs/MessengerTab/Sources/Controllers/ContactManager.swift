//
//  ContactManager.swift
//  Feishu-clone
//
//  Created by Kyle Huang on 2025/4/27.
//

import Foundation

class ContactManager {
    static func parseContacts() -> [Contact] {
        guard let url = Bundle.main.url(forResource: "Contacts", withExtension: "plist") else {
            print("Failed to locate Contacts.plist")
            return []
        }

        guard let data = try? Data(contentsOf: url),
              let contactArray = try? PropertyListDecoder().decode([[String: String]].self, from: data) else {
            print("Failed to parse Contacts.plist")
            return []
        }

        return contactArray.compactMap { dict -> Contact? in
            let name = dict["name"]
            
            guard let latestMsg = dict["latestMsg"],
                  let datetime = dict["datetime"],
                  let typeRaw = dict["type"],
                  let type = ContactType(rawValue: typeRaw) else {
                return nil
            }
            
            return Contact(avatar: nil, name: name ?? "", latestMsg: latestMsg, datetime: datetime, type: type)
        }
    }
}
