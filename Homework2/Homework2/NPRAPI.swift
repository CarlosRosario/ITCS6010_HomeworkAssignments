//
//  NPRAPI.swift
//  Homework2
//
//  Created by Carlos Rosario on 7/23/16.
//  Copyright © 2016 Carlos Rosario. All rights reserved.
//

import Foundation

class NPR_API{
    static let PROGRAMS_API = "http://api.npr.org/list?id=3004&output=JSON"
    static let API_KEY = "MDI1NDYwNTI1MDE0NjkyODgzNDYwNmEyZg000"
    
    static func generateStoryAPIById(id: String) -> String{
        return "http://api.npr.org/query?id=" + id + "&output=JSON&apiKey=" + API_KEY
    }
}