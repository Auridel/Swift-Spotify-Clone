//
//  SearchViewController.swift
//  Swift Spotify Clone
//
//  Created by Олег Ефимов on 20.12.2021.
//

import UIKit

class SearchViewController: UIViewController {
    
    private let searchController: UISearchController = {
        let searchVC = UISearchController(searchResultsController: SearchResultsViewController())
        searchVC.searchBar.placeholder = "Songs, Artists, Albums"
        searchVC.searchBar.searchBarStyle = .minimal
        searchVC.definesPresentationContext = true
        return searchVC
    }()
    
    private let collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { _, _ in
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)))
            item.contentInsets = NSDirectionalEdgeInsets(
                top: 2,
                leading: 7,
                bottom: 2,
                trailing: 7)
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(150)),
                subitem: item,
                count: 2)
            group.contentInsets = NSDirectionalEdgeInsets(
                top: 10,
                leading: 0,
                bottom: 10,
                trailing: 0)
            
            return NSCollectionLayoutSection(group: group)
        }))
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
        configureViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        collectionView.frame = view.bounds
    }
    
    // MARK: Common
    
    private func configureViews() {
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(GenreCollectionViewCell.self,
                                forCellWithReuseIdentifier: GenreCollectionViewCell.identifier)
        
        view.addSubview(collectionView)
    }

}

// MARK: CollectionView

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: GenreCollectionViewCell.identifier,
            for: indexPath) as! GenreCollectionViewCell
        cell.configure(with: "Rock")
        return cell
    }
    
    
}

// MARK: Search Results Updater

extension SearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              let resultsControlles = searchController.searchResultsController as? SearchResultsViewController
        else {
            return
        }
        //update res vc
        print(query)
        //search
    }
    
}
