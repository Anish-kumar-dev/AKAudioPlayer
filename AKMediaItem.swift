//
//  AKMediaItem.swift
//  MyPlayer
//
//  Created by Anish Kumar on 30/12/16.
//  Copyright © 2016 Anish Kumar. All rights reserved.
//

import UIKit
import MediaPlayer

open class AKMediaItem: NSObject {
    var assetURL: URL!
    var mediaItem: MPMediaItem?
    
    init(url: URL) {
        assetURL = url
    }
    
    init(item: MPMediaItem) {
        mediaItem = item
        assetURL = item.value(forProperty: MPMediaItemPropertyAssetURL) as! URL!
    }
    
}
