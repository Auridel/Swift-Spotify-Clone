//
//  SearchViewController.swift
//  Swift Spotify Clone
//
//  Created by Олег Ефимов on 20.12.2021.
//

import UIKit
import Combine
import SafariServices

class SearchViewController: UIViewController {
    
    private var categories = [Category]()
    
    private var cancelable = [AnyCancellable]()
    
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
        applyCombineSearch()
        
        ApiManager.shared.getCategories { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let categories):
                    self?.categories = Optional(categories.categories.items) ?? []
                    self?.collectionView.reloadData()
                case .failure(_):
                    break
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView.frame = view.bounds
    }
    
    // MARK: Common
    
    private func configureViews() {
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CategoryCollectionViewCell.self,
                                forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        
        view.addSubview(collectionView)
    }
    
    /// Debounce search query on type
    private func applyCombineSearch() {
        let publisher = NotificationCenter.default.publisher(
            for: UISearchTextField.textDidChangeNotification,
               object: searchController.searchBar.searchTextField)
        publisher
            .map {
                ($0.object as! UISearchTextField).text ?? ""
            }
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] query in
                guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
                    return
                }
                DispatchQueue.global(qos: .userInteractive).async {
                    self?.performSearch(query)
                }
            }
            .store(in: &cancelable)
    }
    
    /// Does Api Call and update UI
    private func performSearch(_ query: String) {
        ApiManager.shared.getTypedSearchResults(query: query) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self,
                      let resultsController = self.searchController.searchResultsController as? SearchResultsViewController
                else { return }
                switch result {
                case .success(let results):
                    resultsController.delegate = self
                    resultsController.update(with: results)
                case .failure(_):
                    break
                }
            }
        }
    }
}

// MARK: CollectionView

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let category = categories[indexPath.row]
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CategoryCollectionViewCell.identifier,
            for: indexPath) as! CategoryCollectionViewCell
        cell.configure(with: CategoryCollectionViewCellViewModel(
            title: category.name,
            artworkURL: URL(string: category.icons.first?.url ?? "")))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        HapticsManager.shared.vibrateForSelection()
        
        let category = categories[indexPath.row]
        let categoryVC = CategoryViewController(category: category)
        categoryVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(categoryVC, animated: true)
    }
    
}

// MARK: Search Results Updater

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty
        else {
            return
        }
        
        self.performSearch(query)
    }
}


// MARK: SearchResults Delegate

extension SearchViewController: SearchResultsViewControllerDelegate {
    
    func didTapSearchResult(_ result: SearchResult) {
        var controller: UIViewController?
        switch result {
            //TODO: implement native artist page
        case .artist(model: let model):
            guard let url = URL(string: model.external_urls["spotify"] ?? "") else {
                return
            }
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true)
        case .album(model: let model):
            controller = AlbumViewController(album: model)
        case .playlist(model: let model):
            controller = PlaylistViewController(playlist: model)
        case .track(model: let model):
            PlaybackPresenter.shared.startPlayback(from: self,
                                            track: model)
        }
        
        guard let controller = controller else {
            return
        }
        controller.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(controller, animated: true)
    }
    
}
