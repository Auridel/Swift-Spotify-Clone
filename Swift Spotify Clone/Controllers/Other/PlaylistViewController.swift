//
//  PlaylistViewController.swift
//  Swift Spotify Clone
//
//  Created by Олег Ефимов on 20.12.2021.
//

import UIKit

class PlaylistViewController: UIViewController {

    private let playlist: Playlist
    
    init(playlist: Playlist) {
        self.playlist = playlist
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = playlist.name
        view.backgroundColor = .systemBackground
        
        fetchPlaylistDetails(playlist: playlist)
    }
    
    private func fetchPlaylistDetails(playlist: Playlist) {
        ApiManager.shared.getPlaylistDetails(for: playlist) { result in
            switch result {
            case .success(let model):
                print(model)
            case .failure(_):
                break
            }
        }
    }

}
