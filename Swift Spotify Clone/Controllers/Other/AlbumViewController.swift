//
//  AlbumViewController.swift
//  Swift Spotify Clone
//
//  Created by Олег Ефимов on 24.12.2021.
//

import UIKit

class AlbumViewController: UIViewController {
    
    private let album: Album
    
    private var viewModels = [AlbumCollectionViewCellViewModel]()
    
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
        
        configureViews()
        fetchAlbum()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView.frame = view.bounds
    }
    
    // MARK: Common
    
    private func fetchAlbum() {
        ApiManager.shared.getAlbumDetails(for: album) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    self?.tracks = model.tracks.items
                    self?.viewModels = model.tracks.items.compactMap {
                        AlbumCollectionViewCellViewModel(
                            name: $0.name,
                            artistName: $0.artists.first?.name ?? "")
                    }
                    self?.collectionView.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    private func configureViews() {
        collectionView.register(AlbumTrackCollectionViewCell.self,
                                forCellWithReuseIdentifier: AlbumTrackCollectionViewCell.identifier)
        collectionView.register(PlaylistHeaderCollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
    }
    
    
}

// MARK: CollectionView

extension AlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumTrackCollectionViewCell.identifier,
                                                      for: indexPath) as! AlbumTrackCollectionViewCell
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let track = tracks[indexPath.row]
        PlaybackPresenter.startPlayback(from: self,
                                        track: track)
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
            name: album.name,
            ownerName: album.artists.first?.name ?? "",
            description: "Release Date: \(album.release_date.formattedDate())",
            artworkURL: URL(string: album.images.first?.url ?? "")))
        header.delegate = self
        return header
    }
}

// MARK: PlaylistHeader Delegate

extension AlbumViewController: PlaylistHeaderCollectionReusableViewDelegate {
    
    func didTapPlayAll(_ header: PlaylistHeaderCollectionReusableView) {
        PlaybackPresenter.startPlayback(from: self,
                                        tracks: tracks)
    }
    
}

