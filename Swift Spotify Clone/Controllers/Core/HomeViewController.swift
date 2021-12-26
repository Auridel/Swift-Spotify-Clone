//
//  ViewController.swift
//  Swift Spotify Clone
//
//  Created by Олег Ефимов on 19.12.2021.
//

import UIKit

class HomeViewController: UIViewController {
    
    private var sections = [BrowseSectionType]()
    
    private var newAlbums = [Album]()
    
    private var playlists = [Playlist]()
    
    private var tracks = [AudioTrack]()
    
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
        collectionView.register(NewReleaseCollectionViewCell.self,
                                forCellWithReuseIdentifier: NewReleaseCollectionViewCell.identifier)
        collectionView.register(FeaturedPlaylistCollectionViewCell.self,
                                forCellWithReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier)
        collectionView.register(RecommendedTrackCollectionViewCell.self,
                                forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.identifier)
        collectionView.register(TitleHeaderCollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: TitleHeaderCollectionReusableView.identifier)
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
        let supplementaryViews = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(50)),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top)
        ]
        var section: NSCollectionLayoutSection?
        
        switch sectionIdx {
        case 0:
            //            self.createComposeLayoutSection(
            section = Utils.createComposeLayoutSection(
                itemLayoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .fractionalHeight(1.0)),
                itemsInsets: NSDirectionalEdgeInsets(top: 2,
                                                     leading: 2,
                                                     bottom: 2,
                                                     trailing: 2),
                verticalLayoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                           heightDimension: .absolute(390)),
                horizontalLayoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9),
                                                             heightDimension: .absolute(390)),
                verticalCount: 3,
                horizontalCount: 1,
                orthogonalBehavior: .groupPaging)
        case 1:
            section = Utils.createComposeLayoutSection(
                itemLayoutSize: NSCollectionLayoutSize(widthDimension: .absolute(200),
                                                       heightDimension: .absolute(200)),
                itemsInsets: NSDirectionalEdgeInsets(top: 2,
                                                     leading: 2,
                                                     bottom: 2,
                                                     trailing: 2),
                verticalLayoutSize: NSCollectionLayoutSize(widthDimension: .absolute(200),
                                                           heightDimension: .absolute(400)),
                horizontalLayoutSize: NSCollectionLayoutSize(widthDimension: .absolute(200),
                                                             heightDimension: .absolute(400)),
                verticalCount: 2,
                horizontalCount: 1,
                orthogonalBehavior: .continuous)
        case 2:
            section = Utils.createComposeLayoutSection(
                itemLayoutSize:  NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                        heightDimension: .fractionalHeight(1.0)),
                itemsInsets: NSDirectionalEdgeInsets(top: 2,
                                                     leading: 2,
                                                     bottom: 2,
                                                     trailing: 2),
                verticalLayoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                           heightDimension: .absolute(80)),
                horizontalLayoutSize: nil,
                verticalCount: 1,
                horizontalCount: nil,
                orthogonalBehavior: nil)
        default:
            section = Utils.createComposeLayoutSection(
                itemLayoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .fractionalHeight(1.0)),
                itemsInsets: NSDirectionalEdgeInsets(top: 2,
                                                     leading: 2,
                                                     bottom: 2,
                                                     trailing: 2),
                verticalLayoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                           heightDimension: .absolute(390)),
                horizontalLayoutSize: nil,
                verticalCount: 1,
                horizontalCount: nil,
                orthogonalBehavior: nil)
        }
        section?.boundarySupplementaryItems = supplementaryViews
        return section
    }
    
    ///get featured playlists, new releases and recommended tracks
    private func fetchData() {
        let group = DispatchGroup()
        group.enter()
        group.enter()
        group.enter()
        
        var newReleases: NewReleasesResponse?
        var featuredPlaylist: FeaturedPlaylistsResponse?
        var recommendations: RecommendationsResponse?
        
        //new releases
        ApiManager.shared.getNewReleases { result in
            defer {
                group.leave()
            }
            switch result {
            case .success(let model):
                newReleases = model
            case .failure(let error):
                print(error)
            }
        }
        //featured
        ApiManager.shared.getFeaturedPlaylists { result in
            defer {
                group.leave()
            }
            switch result {
            case .success(let model):
                featuredPlaylist = model
            case .failure(let error):
                print(error)
            }
        }
        
        //recommended
        ApiManager.shared.getRecommendedGenres { result in
            switch result {
            case .success(let result):
                let genres = result.genres
                var seeds = Set<String>()
                while seeds.count < 5 {
                    if let randomGenre = genres.randomElement(){
                        seeds.insert(randomGenre)
                    }
                }
                ApiManager.shared.getRecommendations(genres: seeds) { recommendedResult in
                    defer {
                        group.leave()
                    }
                    switch recommendedResult {
                    case .success(let model):
                        recommendations = model
                    case .failure(let error):
                        print(error)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
        group.notify(queue: .main) { [weak self] in
            guard let albums = newReleases?.albums.items,
                  let playlists = featuredPlaylist?.playlists.items,
                  let tracks = recommendations?.tracks
            else {
                return
            }
            
            self?.confugureModels(albums: albums,
                                  playlists: playlists,
                                  tracks: tracks)
        }
    }
    
    private func confugureModels(albums: [Album], playlists: [Playlist], tracks: [AudioTrack]) {
        self.newAlbums = albums
        self.playlists = playlists
        self.tracks = tracks
        
        sections.append(.newReleases(viewModels: albums.compactMap({
            return NewReleasesCellViewModel(name: $0.name,
                                            artworkURL: URL(string: $0.images.first?.url ?? ""),
                                            numberOfTracks: $0.total_tracks,
                                            artistName: $0.artists.first?.name ?? "-")
        })))
        sections.append(.featuredPlaylist(viewModels: playlists.compactMap({
            return FeaturedPlaylistsCellViewModel(name: $0.name,
                                                  artworkURL: URL(string: $0.images.first?.url ?? ""),
                                                  creatorName: $0.owner.display_name)
        })))
        sections.append(.recommendedTracks(viewModels: tracks.compactMap({
            return RecommendedTracksCellViewModel(name: $0.name,
                                                  artistName: $0.artists.first?.name ?? "-",
                                                  artworkURL: URL(string: $0.album?.images.first?.url ?? ""))
        })))
        collectionView.reloadData()
    }
}

// MARK: CollectionView

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionModel = sections[section]
        switch sectionModel {
        case .newReleases(let viewModels):
            return viewModels.count
        case .featuredPlaylist(let viewModels):
            return viewModels.count
        case .recommendedTracks(let viewModels):
            return viewModels.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                     withReuseIdentifier: TitleHeaderCollectionReusableView.identifier,
                                                                     for: indexPath) as? TitleHeaderCollectionReusableView
        else {
            return UICollectionReusableView()
        }
        let sectionModel = sections[indexPath.section]
        header.configure(with: sectionModel.title)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionModel = sections[indexPath.section]
        switch sectionModel {
        case .newReleases(let viewModels):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewReleaseCollectionViewCell.identifier,
                                                          for: indexPath) as! NewReleaseCollectionViewCell
            let viewModel = viewModels[indexPath.row]
            cell.configure(with: viewModel)
            return cell
        case .featuredPlaylist(let viewModels):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier,
                                                          for: indexPath) as! FeaturedPlaylistCollectionViewCell
            cell.configure(with: viewModels[indexPath.row])
            return cell
        case .recommendedTracks(let viewModels):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier,
                                                          for: indexPath) as! RecommendedTrackCollectionViewCell
            cell.configure(with: viewModels[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let sectionModel = sections[indexPath.section]
        switch sectionModel {
        case .newReleases:
            let album = newAlbums[indexPath.row]
            let albumVC = AlbumViewController(album: album)
            albumVC.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(albumVC, animated: true)
        case .featuredPlaylist:
            let playlist = playlists[indexPath.row]
            let playlistVC = PlaylistViewController(playlist: playlist)
            playlistVC.navigationItem.largeTitleDisplayMode = .never
            //push from bottom animation
//            let transition = CATransition()
//            transition.duration = 0.3
//            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//            transition.type = .moveIn
//            transition.subtype = .fromTop
//            navigationController?.view.layer.add(transition, forKey: nil)
            //
            navigationController?.pushViewController(playlistVC, animated: true)
        case .recommendedTracks:
            let track = tracks[indexPath.row]
        }
    }
    
}
