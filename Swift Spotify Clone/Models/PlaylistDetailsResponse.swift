//
//  PlaylistDetailsResponse.swift
//  Swift Spotify Clone
//
//  Created by Олег Ефимов on 24.12.2021.
//

import Foundation

struct PlaylistDetailsResponse: Codable {
    let description: String
    let external_urls: [String: String]
    let id: String
    let images: [ApiImage]
    let name: String
    let tracks: PlaylistsTracksResponse
}

struct PlaylistsTracksResponse: Codable {
    let items: [PlaylistItem]
}

struct PlaylistItem: Codable {
    let track: AudioTrack
}
