//
//  Message.swift
//  MyChats
//
//  Created by Timotius Leonardo Lianoto on 18/02/22.
//

import Foundation

class Message: NSObject {
    var fromId: String?
    var text: String?
    var timestamp: TimeInterval?
    var toId: String?
}
