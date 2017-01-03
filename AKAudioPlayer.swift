//
//  AKAudioPlayer.swift
//  MyPlayer
//
//  Created by Anish Kumar on 30/12/16.
//  Copyright © 2016 Anish Kumar. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

open class AKAudioPlayer: NSObject {
    
    fileprivate var player: AVAudioPlayer?
    
    
    /// The current playlist as an Array of AKMediaItems
    open var playlist: [AKMediaItem]? {
        didSet {
            if playlist?.count ?? 0 > 0 {
                currentItem = playlist?.first
                currentIndex = 0
                playItem(currentItem)
                updateSystemControls()
            }
        }
    }
    
    weak open var delegate: AKAudioPlayerDelegate?
    
    /// The currently loaded item
    open var currentItem: AKMediaItem!
    
    /// The current index of the playlist
    open var currentIndex: Int {
        get {
            return _currentIndex
        }
        set {
            if playlist == nil {
                _currentIndex = 0
                postNotification(AKAudioPlayerNotifications.AKAudioPlayerError)
                return
            }
            // count is unsigned so -1 ( returns true for currentIndex > count
            // need to make sure it's also > 0
            if currentIndex > 0 && currentIndex > playlist!.count {
                // reached the end so loop to beginning
                _currentIndex = 0
            } else if currentIndex < 0 {
                // at the beginning, loop to end
                _currentIndex = playlist!.count - 1
            } else {
                _currentIndex = newValue
            }
            postNotification(AKAudioPlayerNotifications.AKAudioPlayerDidSetPlaylist)
        }
    }
    
    private var _isPlaying = false
    private var _currentIndex = 0
    
    
    /// Is an item currently playing?
    open var isPlaying: Bool {
        return _isPlaying
    }
    open var currentTime: TimeInterval {
        return player?.currentTime ?? 0.0
    }
    
    private static let sharedPlayer = AKAudioPlayer()
    open class var shared: AKAudioPlayer {
        get {
            return sharedPlayer
        }
    }
    
    
    private override init() {
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try? AVAudioSession.sharedInstance().setActive(true)
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
    
    
    /// Play the currently loaded item
    open func play() {
        _isPlaying = true
        player?.play()
        if let strongDelegate = delegate {
            strongDelegate.playerDidPlay(self)
            postNotification(AKAudioPlayerNotifications.AKAudioPlayerDidPlay)
        }
        updateSystemControls()
    }
    
    
    /// Pause playback
    open func pause() {
        _isPlaying = false
        player?.pause()
        if let strongDelegate = delegate {
            strongDelegate.playerDidPause(self)
            postNotification(AKAudioPlayerNotifications.AKAudioPlayerDidPause)
        }
        updateSystemControls()
    }
    
    
    /// Play if not already playing, otherwise pause
    open func togglePlayPause() {
        if _isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    
    /// Play the previous item in the playlist
    open func previous() {
        reversePlaylist()
    }
    
    
    /// Play the next item in the playlist
    open func next() {
        advancePlaylist()
    }
    
    
    //    open func handleRemoteControlEvent(_ receivedEvent: UIEvent!)
    
    
    //MARK:- Playlist Management
    
    private func playItem(_ item: AKMediaItem) {
        
        if let _ = player {
            player?.delegate = nil
            player = nil
        }
        do {
            player = try AVAudioPlayer(contentsOf: item.assetURL)
            currentItem = item
            player?.delegate = self
            
            //TODO: ADD MORE CATCH BLOCK
        } catch {
            player?.delegate = nil
            player = nil
            _isPlaying = false
            return
        }
        if _isPlaying {
            play()
        }
        updateSystemControls()
    }
    
    fileprivate func advancePlaylist() {
        let strongDelegate = delegate
        var time = player?.duration ?? 1
        time = player?.currentTime ?? 0.0 / time
        if time < 1 {
            time = 1
        }
        strongDelegate?.player(self, willAdvancePlaylist: currentItem, atPoint: time)
        postNotification(AKAudioPlayerNotifications.AKAudioPlayerWillAdvancePlaylist)
        currentIndex += 1
        if let nextItem = playlist?[currentIndex] {
            playItem(nextItem)
            strongDelegate?.player(self, didAdvancePlaylist: nextItem)
        }
        postNotification(AKAudioPlayerNotifications.AKAudioPlayerDidAdvancePlaylist)
    }
    
    private func reversePlaylist() {
        let strongDelegate = delegate
        var time = player?.duration ?? 1
        time = player?.currentTime ?? 0.0 / time
        if time < 1 {
            time = 1
        }
        strongDelegate?.player(self, willReversePlaylist: currentItem, atPoint: time)
        postNotification(AKAudioPlayerNotifications.AKAudioPlayerWillReversePlaylist)
        currentIndex -= 1
        if let nextItem = playlist?[currentIndex] {
            playItem(nextItem)
            strongDelegate?.player(self, didReversePlaylist: nextItem)
        }
        postNotification(AKAudioPlayerNotifications.AKAudioPlayerDidReversePlaylist)
    }
    
}

//MARK:- AVAudioPlayerDelegate
extension AKAudioPlayer: AVAudioPlayerDelegate {
    
    /* audioPlayerDidFinishPlaying:successfully: is called when a sound has finished playing. This method is NOT called if the player is stopped due to an interruption. */
    @available(iOS 2.2, *)
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        advancePlaylist()
    }
    
    
    /* if an error occurs while decoding it will be reported to the delegate. */
    @available(iOS 2.2, *)
    public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        
    }
    
    
    /* AVAudioPlayer INTERRUPTION NOTIFICATIONS ARE DEPRECATED - Use AVAudioSession instead. */
    
    /* audioPlayerBeginInterruption: is called when the audio session has been interrupted while the player was playing. The player will have been paused. */
    @available(iOS, introduced: 2.2, deprecated: 8.0)
    public func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        postNotification(AKAudioPlayerNotifications.AKAudioPlayerInterruptionBegan)
    }
    
    
    /* audioPlayerEndInterruption:withOptions: is called when the audio session interruption has ended and this player had been interrupted while playing. */
    /* Currently the only flag is AVAudioSessionInterruptionFlags_ShouldResume. */
    @available(iOS, introduced: 6.0, deprecated: 8.0)
    public func audioPlayerEndInterruption(_ player: AVAudioPlayer, withOptions flags: Int) {
        postNotification(AKAudioPlayerNotifications.AKAudioPlayerInterruptionEnded)
        if flags == AVAudioSessionInterruptionFlags_ShouldResume {
            player.play()
        }
    }
    
}

//MARK:- Util
extension AKAudioPlayer {
    
    //MARK:- System bindings
    
    func handleRemoteControlEvent(_ receivedEvent: UIEvent) {
        
        if receivedEvent.type == .remoteControl {
            switch receivedEvent.subtype {
            case .remoteControlPause:
                pause()
            case .remoteControlPlay:
                play()
            case .remoteControlTogglePlayPause:
                togglePlayPause()
            case .remoteControlPreviousTrack:
                previous()
            case .remoteControlNextTrack:
                next()
            case .remoteControlBeginSeekingBackward:
                fallthrough
            case .remoteControlEndSeekingBackward:
                fallthrough
            case .remoteControlBeginSeekingForward:
                fallthrough
            case .remoteControlEndSeekingForward:
                fallthrough
            default:
                break
            }
        }
    }
    
    func updateSystemControls() {
        
        guard let currentItem = currentItem.mediaItem else {
            return
        }
        var nowPlayingInfo: [String: Any] = [:]
        nowPlayingInfo[MPMediaItemPropertyTitle] = currentItem.value(forProperty: MPMediaItemPropertyTitle) ?? ""
        nowPlayingInfo[MPMediaItemPropertyArtist] = currentItem.value(forProperty: MPMediaItemPropertyArtist) ?? ""
        if let artWork = currentItem.value(forProperty: MPMediaItemPropertyArtwork) {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artWork
        }
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = NSNumber(value: player?.duration ?? 0)
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: player?.currentTime ?? 0)
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = NSNumber(value: 1.0)
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func postNotification(_ notificationName: String) {
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: notificationName), object: self)
    }
}
