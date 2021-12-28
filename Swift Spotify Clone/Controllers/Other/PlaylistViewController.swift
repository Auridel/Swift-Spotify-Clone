//
//  PlaylistViewController.swift
//  Swift Spotify Clone
//
//  Created by Олег Ефимов on 20.12.2021.
//

import UIKit

class PlaylistViewController: UIViewController {
    
    private let playlist: Playlist
    
    private var viewModels = [RecommendedTracksCellViewModel]()
    
    private var tracks = [AudioTrack]()
    
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout(
            sectionProvider: { _, _ -> NSCollectionLayoutSection? in
                let section = Utils.createComposeLayoutSection(
                    itemLayoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                           heightDimension: .fractionalHeight(1.0)),
                    itemsInsets: NSDirectionalEdgeInsets(top: 1,
                                                         leading: 2,
                                                         bottom: 1,
                                                         trailing: 2),
                    verticalLayoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                               heightDimension: .absolute(60)),
                    horizontalLayoutSize: nil,
                    verticalCount: 1,
                    horizontalCount: nil,
                    orthogonalBehavior: nil)
                section.boundarySupplementaryItems = [
                    NSCollectionLayoutBoundarySupplementaryItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .fractionalWidth(1)),
                        elementKind: UICollectionView.elementKindSectionHeader,
                        alignment: .top)
                ]
                return section
            }))
    
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action,
                                                            target: self,
                                                            action: #selector(didTapShareButton))
        
        configureViews()
        
        fetchPlaylistDetails(playlist: playlist)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView.frame = view.bounds
    }
    
    // MARK: Actions
    
    @objc private func didTapShareButton() {
        guard let urlString = playlist.external_urls["spotify"] else {
            return
        }
        let vc = UIActivityViewController(activityItems: ["Check out this playlist on Spotify!", urlString],
                                          applicationActivities: [])
        //next line prevents iPad crash
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    // MARK: Common
    
    private func configureViews() {
        collectionView.register(RecommendedTrackCollectionViewCell.self,
                                forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.identifier)
        collectionView.register(PlaylistHeaderCollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
    }
    
    private func fetchPlaylistDetails(playlist: Playlist) {
        ApiManager.shared.getPlaylistDetails(for: playlist) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    self?.tracks = model.tracks.items.compactMap({ $0.track })
                    self?.viewModels = model.tracks.items.compactMap {
                        RecommendedTracksCellViewModel(
                            name: $0.track.name,
                            artistName: $0.track.artists.first?.name ?? "",
                            artworkURL: URL(string: $0.track.album?.images.first?.url ?? ""))
                    }
                    self?.collectionView.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
}

// MARK: CollectionView

extension PlaylistViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier,
                                                      for: indexPath) as! RecommendedTrackCollectionViewCell
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let track = tracks[indexPath.row]
        PlaybackPresenter.shared.startPlayback(from: self, track: track)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                           withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier,
                                                                           for: indexPath) as? PlaylistHeaderCollectionReusableView
        else {
            return UICollectionReusableView()
        }
        header.configure(with: PlaylistHeaderViewModel(
            name: playlist.name,
            ownerName: playlist.owner.display_name,
            description: playlist.description,
            artworkURL: URL(string: playlist.images.first?.url ?? "")))
        header.delegate = self
        return header
    }
}

// MARK: PlaylistHeaderCollectionReusableViewDelegate

extension PlaylistViewController: PlaylistHeaderCollectionReusableViewDelegate {
    
    func didTapPlayAll(_ header: PlaylistHeaderCollectionReusableView) {
        PlaybackPresenter.shared.startPlayback(from: self,
                                        tracks: tracks)
    }
    
}
