//
//  Global.swift
//  Flash Chat iOS13
//
//  Created by Haven on 2022-04-13.
//  Copyright © 2022 Angela Yu. All rights reserved.
//
import Foundation

enum Identifier {
    static let RegisterToChat = "RegisterToChat"
    static let LoginToChat = "LoginToChat"
    static let ResuableCell = "ReusableCell"
    static let MessageCellNib = "MessageCell"
    
    enum FireStore {
        static let MessageCollection = "FlashChatMessageCollection"
        static let SenderField = "FlashChatMessageSender"
        static let BodyField = "FlashChatMessageBody"
        static let Timestamp = "FlashChatMessageStamp"
    }
}

