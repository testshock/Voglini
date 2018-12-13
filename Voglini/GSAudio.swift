//
//  GSAudio.swift
//  Voglini
//
//  Created by Konstantinos Vogklis on 12/12/2018.
//  Copyright © 2018 Costas Voglis. All rights reserved.
//

import Foundation
import AVFoundation


class GSAudio: NSObject, AVAudioPlayerDelegate {
    
    static let sharedInstance = GSAudio()
    
    private override init() {}
    
    var players = [NSURL:AVAudioPlayer]()
    var duplicatePlayers = [AVAudioPlayer]()
    
    func playSound (soundFileName: String, volume: Float){
        
        let soundFileNameURL = NSURL(fileURLWithPath: Bundle.main.path(forResource: soundFileName, ofType: "wav", inDirectory:"sounds")!)
        
        if let player = players[soundFileNameURL] { //player for sound has been found
            
            if player.isPlaying == false { //player is not in use, so use that one
                player.prepareToPlay()
                player.volume = volume
                player.play()
                
            } else { // player is in use, create a new, duplicate, player and use that instead
                
                let duplicatePlayer = try! AVAudioPlayer(contentsOf: soundFileNameURL as URL)
                //use 'try!' because we know the URL worked before.
                
                duplicatePlayer.delegate = self
                //assign delegate for duplicatePlayer so delegate can remove the duplicate once it's stopped playing
                
                duplicatePlayers.append(duplicatePlayer)
                //add duplicate to array so it doesn't get removed from memory before finishing
                
                duplicatePlayer.prepareToPlay()
                duplicatePlayer.volume = volume
                duplicatePlayer.play()
                
            }
        } else { //player has not been found, create a new player with the URL if possible
            do{
                let player = try AVAudioPlayer(contentsOf: soundFileNameURL as URL)
                players[soundFileNameURL] = player
                player.prepareToPlay()
                player.volume = volume
                player.play()
            } catch {
                print("Could not play sound file!")
            }
        }
    }
    
    func setVolumes(volumes: [Float]){
        var i = 0
        for player in players.values {
            player.volume = volumes[i]
            i = i + 1
        }
    }
    
    func playSounds(soundFileNames: [String]){
        
        for soundFileName in soundFileNames {
            playSound(soundFileName: soundFileName, volume: 0.5)
        }
    }
    
    func playSounds(soundFileNames: [String], startVolume: [Float]){
        var i = 0
        for soundFileName in soundFileNames {
            playSound(soundFileName: soundFileName, volume: startVolume[i])
            i = i + 1
        }
    }
     
    func playSounds(soundFileNames: String...){
        for soundFileName in soundFileNames {
            playSound(soundFileName: soundFileName, volume: 0.5)
        }
    }
    
    /*func playSounds(soundFileNames: [String], withDelay: Double) { //withDelay is in seconds
     for (index, soundFileName) in soundFileNames.enumerated() {
     let delay = withDelay*Double(index)
     let _ = Timer.scheduledTimerWithTimeInterval(delay, target: self, selector: #selector(playSoundNotification(_:)), userInfo: ["fileName":soundFileName], repeats: false)
     }
     }*/
    
    func playSoundNotification(notification: NSNotification) {
        if let soundFileName = notification.userInfo?["fileName"] as? String {
            playSound(soundFileName: soundFileName, volume: 0.5)
        }
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        duplicatePlayers.remove(at:0)
        //duplicatePlayers.remove(at: duplicatePlayers.indexOf(player)!)
        //Remove the duplicate player once it is done
    }
    
}
