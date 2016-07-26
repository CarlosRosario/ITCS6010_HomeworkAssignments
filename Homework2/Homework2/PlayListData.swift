//
//  PlayListData.swift
//  Homework2
//
//  Created by Carlos Rosario on 7/24/16.
//  Copyright © 2016 Carlos Rosario. All rights reserved.
//

import Foundation

// I created this file so that i would have access to the playlist from anywhere in the application but, in a controlled way. 
class PlayListData {
    struct PlayListDataStruct {
        static var playlist : [(title: String, audioURL: String)] = []
        static var isAllPlaying = false
    }
}