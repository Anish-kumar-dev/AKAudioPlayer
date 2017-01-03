//
//  AKAudioPlayerDelegate.swift
//  MyPlayer
//
//  Created by Anish Kumar on 31/12/16.
//  Copyright © 2016 Anish Kumar. All rights reserved.
//

import UIKit

public protocol AKAudioPlayerDelegate : NSObjectProtocol {
    
    
    func playerDidPlay(_ player: AKAudioPlayer!)
    
    func playerDidPause(_ player: AKAudioPlayer!)
    
    
    func player(_ player: AKAudioPlayer!, willAdvancePlaylist currentItem: AKMediaItem!, atPoint normalizedTime: Double)
    
    
    func player(_ player: AKAudioPlayer!, willReversePlaylist currentItem: AKMediaItem!, atPoint normalizedTime: Double)
    
    
    func player(_ player: AKAudioPlayer!, didAdvancePlaylist newItem: AKMediaItem!)
    
    func player(_ player: AKAudioPlayer!, didReversePlaylist newItem: AKMediaItem!)
}
