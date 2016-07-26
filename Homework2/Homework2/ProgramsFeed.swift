//
//  ProgramsFeed.swift
//  Homework2
//
//  Created by Carlos Rosario on 7/23/16.
//  Copyright © 2016 Carlos Rosario. All rights reserved.
//

import Foundation

class ProgramsFeed{
    
    let items: [ProgramsItem]
    let sourceURL: NSURL
    
    init(items programItems:[ProgramsItem], sourceURL newURL: NSURL){
        self.items = programItems
        self.sourceURL = newURL
    }
    
    convenience init? (data: NSData, sourceURL url: NSURL){
        var programItems = [ProgramsItem]()
        
        // Parse through JSON
        var jsonObject: Dictionary<String, AnyObject>?
        
        do{
            jsonObject = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? Dictionary<String,AnyObject>
        } catch {
            // error serializing
            print("error serializing json from data")
        }
        
        guard let feedRoot = jsonObject else {
            return nil
        }
        
        guard let items = feedRoot["item"] as? Array<AnyObject> else {
            return nil
        }
        
        for item in items {
            
            guard let itemDictionary = item as? Dictionary<String,AnyObject> else {
                continue
            }
            
            // grab the id
            guard let id = itemDictionary["id"] as? String else{
                continue
            }
            
            // grab the title
            guard let titleDictionary = itemDictionary["title"] as? Dictionary<String,AnyObject> else {
                continue
            }
            
            guard let title = titleDictionary["$text"] as? String else{
                continue
            }
            
            // grab the additional information
            guard let additionalInfoDictionary = itemDictionary["additionalInfo"] as? Dictionary<String, AnyObject> else {
                continue
            }
            
            guard let additionalInfo = additionalInfoDictionary["$text"] as? String else{
                continue
            }
            
            // remove html encodings from additionalInfo with regex
            let additionalInfoScrubbed = additionalInfo.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
            
            programItems.append(ProgramsItem(id: id, title: title, additionalInfo: additionalInfoScrubbed))
        }
        self.init(items: programItems, sourceURL: url)
    }
}
