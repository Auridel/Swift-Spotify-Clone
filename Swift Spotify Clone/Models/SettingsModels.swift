//
//  SettingsModel.swift
//  Swift Spotify Clone
//
//  Created by Олег Ефимов on 21.12.2021.
//

import Foundation

struct Section {
    let title: String
    let options: [Option]
}

struct Option {
    let title: String
    let handler: () -> Void
}
