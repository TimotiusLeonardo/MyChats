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
    var chatPartnerName: String?
    var imageUrl: String?
    var imageHeight: NSNumber?
    var imageWidth: NSNumber?
    
    func chatPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
    
    init(dictionary: [String: Any]) {
        super.init()
        
        guard let fromId = dictionary["fromId"] as? String,
              let timestamp = dictionary["timestamp"] as? TimeInterval,
              let toId = dictionary["toId"] as? String else {
                  return
              }
        
        if let text = dictionary["text"] as? String {
            self.text = text
        }
        
        if let imageUrl = dictionary["imageUrl"] as? String {
            self.imageUrl = imageUrl
            self.imageWidth = dictionary["imageWidth"] as? NSNumber
            self.imageHeight = dictionary["imageHeight"] as? NSNumber
        }
        
        self.fromId = fromId
        self.timestamp = timestamp
        self.toId = toId
    }
}
