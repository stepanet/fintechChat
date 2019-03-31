//
//  Message.swift
//  fintechChat
//
//  Created by Jack Sp@rroW on 19/03/2019.
//  Copyright © 2019 Jack Sp@rroW. All rights reserved.
//

import Foundation

class MessageType: Codable {
    var eventType: String
    var text: String
    var messageId: String

    init(text: String) {
        self.text = text
        self.eventType = "TextMessage"
        self.messageId = MessageType.generateMessageId()
    }

    public static func generateMessageId() -> String {
        return "\(arc4random_uniform(UINT32_MAX))+\(Date.timeIntervalSinceReferenceDate)".data(using: .utf8)!.base64EncodedString()
    }
}
