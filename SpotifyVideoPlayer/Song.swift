//
//  Song.swift
//  SpotifyVideoPlayer
//
//  Created by Ronaldo Avalos on 25/03/25.
//

import SwiftUI

struct Video: Hashable {
    let videoID : String
}

struct Song: Hashable {
    let name: String
    let artist: [String]
    let albumImage: String
    let isSave: Bool
    let listenersMonthly: String
    let duration: Double
    let video: Video
    let lyric1: String
    let lyric2: String
    let color: Color
    let about: String
    
    static let songs: [Song] = [
        .init(name: "Die With A Smile",
              artist: ["Lady Gaga", "Bruno Mars"],
              albumImage: "Lady-Gaga",
              isSave: true,
              listenersMonthly: "119.7",
              duration: 251.0, video: .init(videoID: "video 1"), lyric1: "I, I just woke up from a dream \nWhere you and I had to say goodbye \nAnd I don't know what it all means", lyric2: "But since I survived, I realized", color: .blue, about: "About"),
        
            .init(name: "Espresso", artist: ["Sabrina Carpenter"], albumImage: "Sabrina-Carpenter", isSave: true, listenersMonthly: "66.9", duration: 178.0, video: .init(videoID: "video 2"), lyric1: "Now he's thinkin' 'bout me every night, oh \nIs it that sweet? I guess so \nSay you can't sleep, baby, I know", lyric2: "That's that me espresso", color: .gray, about: "sc-about"),
        
            .init(name: "BAILE INoLVIDABLE", artist: ["Bad Bunny"], albumImage: "Bad-Bunny", isSave: true, listenersMonthly: "83.8", duration: 251.0, video: .init(videoID: "video 3"), lyric1: "Pensaba que contigo iba a envejecer \nEn otra vida, en otro mundo podrá ser \nEn esta solo queda irme un día", lyric2: "Y solamente verte en el atardecer", color: .indigo, about: "bb-about")
        
    ]
}
