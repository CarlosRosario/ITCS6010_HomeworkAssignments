//
//  NoImageStoryTableViewCell.swift
//  Homework2
//
//  Created by Carlos Rosario on 7/24/16.
//  Copyright © 2016 Carlos Rosario. All rights reserved.
//

import UIKit
import AVFoundation

class NoImageStoryTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var teaser: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var audioToggleButton: UIButton!
    @IBOutlet weak var audioProgressView: UIProgressView!
    
    var myPlayer = AVPlayer()
    var playerItem: AVPlayerItem?
    var isAudioPlaying = false
    
    var data: (title: String, teaser: String, date: String, audioURL: String)? {
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

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func updateUI(){
        // reset any existing information
        title?.text = nil
        teaser?.text = nil
        date?.text = nil
        
        // set developer name
        title?.text = data?.title
        
        // set app title
        teaser?.text = data?.teaser
        
        // set release date
        date?.text = data?.date

        teaser.lineBreakMode = NSLineBreakMode.ByWordWrapping
        teaser.numberOfLines = 0
    }
    
    var progress:Float = 0{
        didSet{
            let animated = progress != 0
            audioProgressView.setProgress(progress, animated: animated)
        }
    }
    
    @IBAction func toggleAudio(sender: UIButton) {
        //print("playing \(data?.audioURL)")
        
        if(!isAudioPlaying){
            myPlayer.volume = 1.0
            myPlayer.play()
            audioToggleButton.setTitle("Stop", forState: .Normal)
            isAudioPlaying = true
        }
        else {
            myPlayer.pause()
            audioToggleButton.setTitle("Play", forState: .Normal)
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
    
}
