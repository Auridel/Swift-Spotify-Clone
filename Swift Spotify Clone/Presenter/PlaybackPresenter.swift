//
//  PlaybackPresenter.swift
//  Swift Spotify Clone
//
//  Created by Олег Ефимов on 28.12.2021.
//

import UIKit

final class PlaybackPresenter {
    
    public static func startPlayback(from viewController: UIViewController, track: AudioTrack) {
        presentPlayerVC(with: track.name, from: viewController)
    }
    
    public static func startPlayback(from viewController: UIViewController, tracks: [AudioTrack]) {
        presentPlayerVC(with: tracks.first?.name ?? "", from: viewController)
    }
    
    private static func presentPlayerVC(with title: String, from viewController: UIViewController) {
        let playerVC = PlayerViewController()
        playerVC.title = title
        viewController.present(UINavigationController(rootViewController: playerVC), animated: true)
    }
}
