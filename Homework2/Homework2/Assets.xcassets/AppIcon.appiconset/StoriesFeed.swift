//
//  StoriesFeed.swift
//  Homework2
//
//  Created by Carlos Rosario on 7/24/16.
//  Copyright © 2016 Carlos Rosario. All rights reserved.
//

import Foundation

class StoriesFeed {
    
    let items: [StoryItem]
    let sourceURL: NSURL
    
    init(items storyItems:[StoryItem], sourceURL newURL: NSURL){
        self.items = storyItems
        self.sourceURL = newURL
    }
    
    convenience init? (data: NSData, sourceURL url: NSURL){
        var storyItems = [StoryItem]()
        
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
        
        guard let list = feedRoot["list"] as? Dictionary<String,AnyObject> else {
            return nil
        }
        
        guard let stories = list["story"] as? Array<AnyObject> else{
            return nil
        }
        
        for story in stories { // each "story" is a dictionary
            
            guard let storyDictionary = story as? Dictionary<String,AnyObject> else {
                continue
            }
            
            // grab the title
            guard let titleDictionary = storyDictionary["title"] as? Dictionary<String,AnyObject> else{
                continue
            }
            
            guard let title = titleDictionary["$text"] as? String else{
                continue
            }
            
            // grab the teaser
            guard let teaserDictionary = storyDictionary["teaser"] as? Dictionary<String,AnyObject> else {
                continue
            }
            
            guard let teaser = teaserDictionary["$text"] as? String else{
                continue
            }
            
            // grab the date (story, pub, or last modified)
            guard let storyDateDictionary = storyDictionary["storyDate"] as? Dictionary<String,AnyObject> else{
                return nil
            }
            
            guard let publicationDateDictionary = storyDictionary["pubDate"] as? Dictionary<String,AnyObject> else{
                return nil
            }
            
            guard let lastModifiedDateDictionary = storyDictionary["lastModifiedDate"] as? Dictionary<String,AnyObject> else{
                return nil
            }
            
            var storyDate: String? = nil
            if let tempStoryDate = storyDateDictionary["$text"] as? String{
                storyDate = tempStoryDate
            }
            
            if storyDate == nil {
                if let tempPublicationDate = publicationDateDictionary["$text"] as? String{
                    storyDate = tempPublicationDate
                }
                else if let tempLastModifiedDate = lastModifiedDateDictionary["$text"] as? String{
                    storyDate = tempLastModifiedDate
                } else {
                    storyDate = "No Date Found"
                }
            }
            
            var finalStoryDate = storyDate!
            
            
            
//            guard let storyDate = storyDictionary["storyDate"] as? String else{
//                return nil
//            }
            
            // grab audio url
            guard let audioArray = storyDictionary["audio"] as? Array<AnyObject> else {
                continue
            }
            
            guard let audioDictionary = audioArray[0] as? Dictionary<String,AnyObject> else{
                continue
            }
            
            guard let audioFormatDictionary = audioDictionary["format"] as? Dictionary<String, AnyObject> else{
                continue
            }
            
            guard let mp3Array = audioFormatDictionary["mp3"] as? Array<AnyObject> else{
                continue
            }
            
            guard let mp3Object = mp3Array[0] as? Dictionary<String,AnyObject> else{
                continue
            }
            
            guard let audioURL = mp3Object["$text"] as? String else{
                continue
            }
            
            // grab thumbnail url (might not exist)
            var thumbnailURL: String? = nil
            if let thumbnailDictionary = storyDictionary["thumbnail"] as? Dictionary<String, AnyObject> {
                if let mediumThumbNailDictionary = thumbnailDictionary["large"] as? Dictionary<String, AnyObject>{
                    if let tempThumbNailUrl = mediumThumbNailDictionary["$text"] as? String {
                        thumbnailURL = tempThumbNailUrl
                    }
                }
                
            }
            
            // remove html encodings from title with regex
            let titleScrubbed = title.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
            
            // remove html encodings from teaser with regex
            let teaserScrubbed = teaser.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
            
            // remove unnecessary characters from date string
            let range = finalStoryDate.endIndex.advancedBy(-5)..<finalStoryDate.endIndex
            finalStoryDate.removeRange(range)
            
            storyItems.append(StoryItem(title: titleScrubbed, teaser: teaserScrubbed, storyDate: finalStoryDate, audioURL: audioURL, thumbnailURL: thumbnailURL))
        }
        self.init(items: storyItems, sourceURL: url)
    }
    
}