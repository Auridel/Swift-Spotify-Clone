//
//  Enums.swift
//  Swift Spotify Clone
//
//  Created by Олег Ефимов on 24.12.2021.
//

import Foundation

enum BrowseSectionType {
    case newReleases(viewModels: [NewReleasesCellViewModel]),
         featuredPlaylist(viewModels: [FeaturedPlaylistsCellViewModel]),
         recommendedTracks(viewModels: [RecommendedTracksCellViewModel])
    
    var title: String {
        switch self {
        case .newReleases(_):
            return "New Releases"
        case .featuredPlaylist(_):
            return "Featured Playlists"
        case .recommendedTracks(_):
            return "Recommended Tracks"
        }
    }
}
