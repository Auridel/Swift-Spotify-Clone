//
//  TabBarViewController.swift
//  Swift Spotify Clone
//
//  Created by Олег Ефимов on 20.12.2021.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTabBar()
    }

    private func configureTabBar() {
        let homeVC = HomeViewController()
        let searchVC = SearchViewController()
        let libraryVC = LibraryViewController()
        
        homeVC.title = "Browse"
        searchVC.title = "Search"
        libraryVC.title = "Library"
        homeVC.navigationItem.largeTitleDisplayMode = .always
        searchVC.navigationItem.largeTitleDisplayMode = .always
        libraryVC.navigationItem.largeTitleDisplayMode = .always
        
        let homeNC = UINavigationController(rootViewController: homeVC)
        let searchNC = UINavigationController(rootViewController: searchVC)
        let libraryNC = UINavigationController(rootViewController: libraryVC)
        
        homeNC.tabBarItem = UITabBarItem(title: "Home",
                                         image: UIImage(systemName: "house"),
                                         tag: 1)
        searchNC.tabBarItem = UITabBarItem(title: "Search",
                                         image: UIImage(systemName: "magnifyingglass"),
                                         tag: 2)
        libraryNC.tabBarItem = UITabBarItem(title: "Library",
                                         image: UIImage(systemName: "music.note.list"),
                                         tag: 3)
        
        homeNC.navigationBar.prefersLargeTitles = true
        homeNC.navigationBar.tintColor = .label
        searchNC.navigationBar.prefersLargeTitles = true
        searchNC.navigationBar.tintColor = .label
        libraryNC.navigationBar.prefersLargeTitles = true
        libraryNC.navigationBar.tintColor = .label
        
        setViewControllers([homeNC, searchNC, libraryNC], animated: false)
    }
}
