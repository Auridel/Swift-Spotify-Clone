//
//  LibraryToggleView.swift
//  Swift Spotify Clone
//
//  Created by Олег Ефимов on 29.12.2021.
//

import UIKit

protocol LibraryToggleViewDelegate: AnyObject {
    func libraryToggleViewDidTapPlaylists()
    func libraryToggleViewDidTapAlbums()
}

class LibraryToggleView: UIView {
    
    enum LibraryToggleState {
        case playlists, albums
    }
    
    weak var delegate: LibraryToggleViewDelegate?
    
    internal var state: LibraryToggleState = .playlists
    
    private let playlistButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label,
                             for: .normal)
        button.setTitle("Playlists",
                        for: .normal)
        return button
    }()
    
    private let albumsButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label,
                             for: .normal)
        button.setTitle("Albums",
                        for: .normal)
        return button
    }()
    
    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 4
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        playlistButton.addTarget(self,
                                 action: #selector(didTapPlaylists),
                                 for: .touchUpInside)
        albumsButton.addTarget(self,
                               action: #selector(didTapAlbums),
                               for: .touchUpInside)
        
        addSubview(playlistButton)
        addSubview(albumsButton)
        addSubview(indicatorView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        playlistButton.frame = CGRect(
            x: 0,
            y: 0,
            width: 100,
            height: 40)
        albumsButton.frame = CGRect(
            x: playlistButton.right,
            y: 0,
            width: 100,
            height: 40)
        layoutIndicator()
    }
    
    // MARK: Action
    
    @objc private func didTapPlaylists() {
        state = .playlists
        animateIndicator()
        delegate?.libraryToggleViewDidTapPlaylists()
    }
    
    @objc private func didTapAlbums() {
        state = .albums
        animateIndicator()
        delegate?.libraryToggleViewDidTapAlbums()
    }
    
    // MARK: Common
    
    public func updateIndicator(for indicatorState: LibraryToggleState) {
        state = indicatorState
        animateIndicator()
    }
    
    private func animateIndicator() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.layoutIndicator()
        }
    }
    
    private func layoutIndicator() {
        switch state {
        case .playlists:
            indicatorView.frame = CGRect(
                x: 0,
                y: playlistButton.bottom,
                width: 100,
                height: 3)
        case .albums:
            indicatorView.frame = CGRect(
                x: 100,
                y: playlistButton.bottom,
                width: 100,
                height: 3)
        }
    }

}
