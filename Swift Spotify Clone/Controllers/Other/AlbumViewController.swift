//
//  AlbumViewController.swift
//  Swift Spotify Clone
//
//  Created by Олег Ефимов on 24.12.2021.
//

import UIKit

class AlbumViewController: UIViewController {
    
    private let album: Album
    
    init(album: Album) {
        self.album = album
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = album.name
        view.backgroundColor = .systemBackground
        
        fetchAlbum()
    }
    
    private func fetchAlbum() {
        ApiManager.shared.getAlbumDetails(for: album) { result in
            switch result {
            case .success(let model):
                print(model)
            case .failure(_):
                break
            }
        }
    }
}
