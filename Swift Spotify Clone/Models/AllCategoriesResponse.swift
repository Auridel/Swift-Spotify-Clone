//
//  AllCategoriesResponse.swift
//  Swift Spotify Clone
//
//  Created by Олег Ефимов on 26.12.2021.
//

import Foundation

struct AllCategoriesResponse: Codable {
    let categories: Categories
}

struct Categories: Codable {
    let items: [Category]
}

struct Category: Codable {
    let id: String
    let name: String
    let icons: [ApiImage]
}
