//
//  Message.swift
//  Buddies
//
//  Created by Grant Yurisic on 3/28/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import Foundation
import MessageKit

class Message: MessageType {
    
    var messageId: String
    var sender: Sender
    var sentDate: Date
    var kind: MessageKind
    var content: String
    
    
    init(text: String, sender: Sender, messageId: String, date: Date) {
        self.kind = .text(text)
        self.sender = sender
        self.messageId = messageId
        self.sentDate = date
        self.content = text
    }

    
}
