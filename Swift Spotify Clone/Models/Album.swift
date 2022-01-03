//
//  Album.swift
//  Swift Spotify Clone
//
//  Created by Олег Ефимов on 03.01.2022.
//

import Foundation

struct AlbumsResponse: Codable {
    let items: [Album]
}

struct Album: Codable {
    let album_type: String?
    let available_markets: [String]?
    let id: String
    var images: [ApiImage]
    let name: String
    let release_date: String
    let total_tracks: Int
    let artists: [Artist]
}

struct LibraryAlbumResponse: Codable {
    let items: [LibraryAlbum]
}

struct LibraryAlbum: Codable {
    let album: Album
}
