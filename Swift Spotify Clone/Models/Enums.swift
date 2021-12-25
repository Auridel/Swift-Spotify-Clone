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
}
