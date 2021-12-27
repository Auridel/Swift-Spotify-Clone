//
//  CommonProtocols.swift
//  Swift Spotify Clone
//
//  Created by Олег Ефимов on 28.12.2021.
//

import Foundation

protocol TypedUITableViewCell {
    associatedtype T
    static var viewModelType: T.Type { get }
    func configure(with viewModel: T)
}
