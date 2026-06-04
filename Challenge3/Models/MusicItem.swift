//
//  MusicItem.swift
//  Challenge3
//
//  Created by Johnny Khang on 04/06/26.
//

//  MusicItem.swift
//  Challenge3

import Foundation
import SwiftData

@Model
final class MusicItem {
    var songID: String          // MusicKit's MusicItemID as String
    var title: String
    var artistName: String
    var albumTitle: String?
    var artworkURL: String?     // cache the artwork URL as string

    init(
        songID: String,
        title: String,
        artistName: String,
        albumTitle: String? = nil,
        artworkURL: String? = nil
    ) {
        self.songID      = songID
        self.title       = title
        self.artistName  = artistName
        self.albumTitle  = albumTitle
        self.artworkURL  = artworkURL
    }
}
