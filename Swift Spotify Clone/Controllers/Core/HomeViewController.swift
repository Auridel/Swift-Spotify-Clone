//
//  ViewController.swift
//  Swift Spotify Clone
//
//  Created by Олег Ефимов on 19.12.2021.
//

import UIKit

enum BrowseSectionType {
    case newReleases, featuredPlaylist, recommendedTracks
}

class HomeViewController: UIViewController {
    
    private let collectionView: UICollectionView = UICollectionView(frame: .zero,
                                                                    collectionViewLayout: UICollectionViewCompositionalLayout { sectionIdx, _ -> NSCollectionLayoutSection? in
        return HomeViewController.createSectionLayout(sectionIdx: sectionIdx)
    })
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.tintColor = .label
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapSettings))
        
        configureCollectionView()
        view.addSubview(spinner)
        fetchData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView.frame = view.bounds
    }
    
    private func configureCollectionView() {
        collectionView.register(UICollectionViewCell.self,
                                forCellWithReuseIdentifier: "cell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
    }
    
    // MARK: Actions
    
    @objc private func didTapSettings() {
        let settingsVC = SettingsViewController()
        settingsVC.title = "Settings"
        settingsVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    // MARK: Common
    
    private static func createSectionLayout(sectionIdx: Int) -> NSCollectionLayoutSection? {
        //item
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                             heightDimension: .fractionalHeight(1.0)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 2,
                                                     leading: 2,
                                                     bottom: 2,
                                                     trailing: 2)
        //vertical group in horizontal group
        let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                                                  heightDimension: .absolute(390)),
                                                               subitem: item,
                                                               count: 3)
        
        let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9),
                                                                                        heightDimension: .absolute(390)),
                                                     subitem: verticalGroup,
                                                     count: 1)
        //section
        let section = NSCollectionLayoutSection(group: horizontalGroup)
        section.orthogonalScrollingBehavior = .groupPaging
        return section
    }
    
    ///get featured playlists, new releases and recommended tracks
    private func fetchData() {
        ApiManager.shared.getRecommendedGenres { result in
            switch result {
            case .success(let result):
                print(result)
                let genres = result.genres
                var seeds = Set<String>()
                while seeds.count < 5 {
                    if let randomGenre = genres.randomElement(){
                        seeds.insert(randomGenre)
                    }
                }
                ApiManager.shared.getRecommendations(genres: seeds) { result in
                    switch result {
                    case .success(let model):
                        print(model)
                    case .failure(_):
                        break
                    }
                }
            case .failure(_):
                break
            }
        }
    }
}

// MARK: CollectionView

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell",
                                                      for: indexPath)
        cell.backgroundColor = .systemGreen
        return cell
    }
    
}
