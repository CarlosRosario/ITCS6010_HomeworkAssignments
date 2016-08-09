//
//  SideMenuTableViewCell.swift
//  Homework2
//
//  Created by Carlos Rosario on 7/24/16.
//  Copyright © 2016 Carlos Rosario. All rights reserved.
//

import UIKit
import AVFoundation

class SideMenuTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var playAudioButton: UIButton!
    @IBOutlet weak var audioProgressView: UIProgressView!
    @IBOutlet weak var playAllAudioButton: UIButton!
    
    weak var parentTableView : UITableView?
    
    var myPlayer = AVPlayer()
    var playerItem: AVPlayerItem?
    var isAudioPlaying = false
    
    var data: (title: String, audioURL: String)? {
        didSet{
            updateUI()
            let url = convertStringToNSURL((data?.audioURL)!)
            playerItem = AVPlayerItem(URL: url!)
            myPlayer = AVPlayer(playerItem: self.playerItem!)
            
            NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ImageStoryTableViewCell.updateAudioProgress), userInfo: nil, repeats: true)
            audioProgressView.setProgress(0, animated: true)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func updateUI(){
        // reset any existing information
        title?.text = nil

        // set title
        title?.text = data?.title
        
        title.lineBreakMode = NSLineBreakMode.ByWordWrapping
        title.numberOfLines = 0
    }
    
    var progress:Float = 0{
        didSet{
            let animated = progress != 0
            audioProgressView.setProgress(progress, animated: animated)
        }
    }
    
    var allPlayListPlayer = AVPlayer()
    var allPlayListPlayerItem: AVPlayerItem?
    var currentClip = 0
    @IBAction func playAllInPlaylist(sender: UIButton) {
        
        if(PlayListData.PlayListDataStruct.isAllPlaying){
            PlayListData.PlayListDataStruct.isAllPlaying = false
            allPlayListPlayer.pause()
            playAllAudioButton.setTitle("Play All!", forState: UIControlState.Normal)
            NSNotificationCenter.defaultCenter().removeObserver(self)
        }
        else {
            // Make sure not to play audio over existing audio
            if(isAnyAudioPlaying()){
                return
            }
            //playAudioButton.setImage(UIImage(named: "play-button.png"), forState: UIControlState.Normal)
            isAudioPlaying = false
            
            // Set up AVPlayer to play every clip in the playlist - i want this AVPlayer to be completely separate from the AVPlayer that handles individual clips
            if !PlayListData.PlayListDataStruct.playlist.isEmpty{
                let url = convertStringToNSURL(PlayListData.PlayListDataStruct.playlist[currentClip].audioURL)
                allPlayListPlayerItem = AVPlayerItem(URL: url!)
                allPlayListPlayer = AVPlayer(playerItem: self.allPlayListPlayerItem!)
                
                // Register to be notified for when a clip plays. This way i know when to play the "next" clip in the playlist
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SideMenuTableViewCell.playerDidFinishPlaying(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
                
                // Play clip
                allPlayListPlayer.volume = 1
                allPlayListPlayer.play()
                
                // Update button text
                playAllAudioButton.setTitle("Stop Playing", forState: UIControlState.Normal)
                PlayListData.PlayListDataStruct.isAllPlaying = true
            }
            else {
                // show toast that playlist is empty
                print("playlist is empty")
            }
        }
    }
    
    func playerDidFinishPlaying(note: NSNotification){
        currentClip = currentClip + 1
        
        // if currentClip = playlist.count + 1 that means that all clips have played and we should now stop
        print(PlayListData.PlayListDataStruct.playlist.count)
        if(currentClip == PlayListData.PlayListDataStruct.playlist.count){
            currentClip = 0
            allPlayListPlayer.pause()
            allPlayListPlayer.rate = 0 // stop the player
            playAllAudioButton.setTitle("Play All!", forState: UIControlState.Normal)
            PlayListData.PlayListDataStruct.isAllPlaying = false
        }
        // otherwise we should play the next clip in the playlist
        else {
            let url = convertStringToNSURL(PlayListData.PlayListDataStruct.playlist[currentClip].audioURL)
            allPlayListPlayerItem = AVPlayerItem(URL: url!)
            allPlayListPlayer = AVPlayer(playerItem: self.allPlayListPlayerItem!)
            allPlayListPlayer.play()
            playAllAudioButton.setTitle("Stop Playing", forState: UIControlState.Normal)
            PlayListData.PlayListDataStruct.isAllPlaying = true
        }
    }
    
    @IBAction func playClip(sender: UIButton) {
        //print("playing \(data?.audioURL)")
        
        if(!isAudioPlaying && !PlayListData.PlayListDataStruct.isAllPlaying){
            myPlayer.volume = 1.0
            myPlayer.play()
            playAudioButton.setImage(UIImage(named: "stop-button.png"), forState: UIControlState.Normal)
            isAudioPlaying = true
        }
        else {
            myPlayer.pause()
            playAudioButton.setImage(UIImage(named: "play-button.png"), forState: UIControlState.Normal)
            isAudioPlaying = false
        }
    }
    
    // Selector function responsible for making progressbar update gradually as audio plays
    func updateAudioProgress(){
        if myPlayer.rate != 0 && myPlayer.error == nil {
            let percentageComplete = Float(CMTimeGetSeconds((self.playerItem?.currentTime())!)) / Float(CMTimeGetSeconds((self.playerItem?.duration)!))
            print(percentageComplete)
            self.progress = percentageComplete
        }
    }
    
    private func convertStringToNSURL(url: String) -> NSURL? {
        return NSURL(string: url)
    }
    
    // Crappy hack i made up to avoid having dual audio
    private func isAnyAudioPlaying() -> Bool {
        //get section of interest i.e: first section (0)
        for (var row = 0; row < parentTableView!.numberOfRowsInSection(1); row = row + 1)
        {
            let indexPath = NSIndexPath(forRow: row, inSection: 1)
            //following line of code is for invisible cells
            parentTableView!.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
            
            let cell = parentTableView!.cellForRowAtIndexPath(indexPath) as? SideMenuTableViewCell
            
            if(cell?.myPlayer.rate != 0 || (cell?.isAudioPlaying)!){
                return true
            }
        }
        return false
    }
}
