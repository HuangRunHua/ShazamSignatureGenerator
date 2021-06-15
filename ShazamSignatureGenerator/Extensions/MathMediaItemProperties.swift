//
//  MathMediaItemProperties.swift
//  ShazamSignatureGenerator
//
//  Created by Runhua Huang on 2021/6/15.
//

import Foundation
import ShazamKit


extension SHMediaItemProperty {
    static let singer = SHMediaItemProperty("singer")
    static let song = SHMediaItemProperty("song")
}

extension SHMediaItem {
    var song: Int? {
        return self[.song] as? Int
    }
}
