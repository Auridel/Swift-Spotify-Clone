//
//  LibraryViewController.swift
//  Swift Spotify Clone
//
//  Created by Олег Ефимов on 20.12.2021.
//

import UIKit

class LibraryViewController: UIViewController {
    
    private let playlistsVC = LibraryPlaylistsViewController()
    
    private let albumsVC = LibraryAlbumsViewController()
    
    private let toggleView = LibraryToggleView()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        return scrollView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
        configureViews()
        addChildren()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top + 55,
            width: view.width,
            height: view.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom - 55)
        toggleView.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top,
            width: 200,
            height: 55)
    }
    
    // MARK: Common
    
    private func configureViews() {
        scrollView.delegate = self
        toggleView.delegate = self
        
        view.addSubview(scrollView)
        view.addSubview(toggleView)
        
        scrollView.contentSize = CGSize(
            width: view.width * 2,
            height: scrollView.height)
    
        
    }
    
    private func addChildren() {
        addChild(playlistsVC)
        scrollView.addSubview(playlistsVC.view)
        playlistsVC.view.frame = CGRect(
            x: 0,
            y: 0,
            width: scrollView.width,
            height: scrollView.height)
        playlistsVC.didMove(toParent: self)
        
        addChild(albumsVC)
        scrollView.addSubview(albumsVC.view)
        albumsVC.view.frame = CGRect(
            x: view.width,
            y: 0,
            width: scrollView.width,
            height: scrollView.height)
        albumsVC.didMove(toParent: self)
    }
}


// MARK: ScrollView Delegate

extension LibraryViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x >= view.width - 100 {
            toggleView.updateIndicator(for: .albums)
        } else if scrollView.contentOffset.x <= 100 {
            toggleView.updateIndicator(for: .playlists)
        }
    }
}

// MARK: ToggleView Delegate

extension LibraryViewController: LibraryToggleViewDelegate {
    
    func libraryToggleViewDidTapPlaylists() {
        scrollView.setContentOffset(
            .zero,
            animated: true)
    }
    
    func libraryToggleViewDidTapAlbums() {
        scrollView.setContentOffset(
            CGPoint(x: view.width, y: 0),
            animated: true)
    }
    
    
}
