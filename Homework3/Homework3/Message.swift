//
//  Message.swift
//  Homework3
//
//  Created by Carlos Rosario on 8/6/16.
//  Copyright © 2016 Carlos Rosario. All rights reserved.
//

import Foundation

class Message {
    var messageText: String?
    var fromID: String?
    var fromEmail: String?
    var toID: String?
    var toEmail: String?
    var messageID: String?
    var fromImageURL: String?
    var fromName: String?
    var hasMessageBeenRead: String? // 0 means message has not been read, 1 means message has been read
}