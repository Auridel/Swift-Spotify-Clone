//
//  RecommendatiosResponse.swift
//  Swift Spotify Clone
//
//  Created by Олег Ефимов on 23.12.2021.
//

import Foundation

struct RecommendationsResponse: Codable {
    let tracks: [AudioTrack]
}

