//
//  Message.swift
//  MyChats
//
//  Created by Timotius Leonardo Lianoto on 18/02/22.
//

import Foundation
import Firebase

class Message: NSObject {
    var fromId: String?
    var text: String?
    var timestamp: TimeInterval?
    var toId: String?
    
    func chatPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
}
