//
//  SearchResult.swift
//  Swift Spotify Clone
//
//  Created by Олег Ефимов on 27.12.2021.
//

import Foundation

enum SearchResult {
    case artist(model: Artist), album(model: Album), playlist(model: Playlist), track(model: AudioTrack)
}

struct SearchSection {
    let title: String
    let results: [SearchResult]
}

struct FiltredSearchResults {
    var artists: [SearchResult]
    var albums: [SearchResult]
    var tracks: [SearchResult]
    var playlists: [SearchResult]
}
