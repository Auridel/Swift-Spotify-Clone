//
//  LibraryAlbumsViewController.swift
//  Swift Spotify Clone
//
//  Created by Олег Ефимов on 29.12.2021.
//

import UIKit

class LibraryAlbumsViewController: UIViewController {
    
    private var albums = [Album]()
    
    private let noAlbumsView = ActionLabelView()
    
    private var observer: NSObjectProtocol?
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero,
                                    style: .grouped)
        tableView.register(SearchResultsSubtitleTableViewCell.self,
                           forCellReuseIdentifier: SearchResultsSubtitleTableViewCell.identifier)
        tableView.isHidden = true
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        configureViews()
        configureObserver()
        fetchUserAlbums()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
        noAlbumsView.frame = CGRect(x: 25,
                                    y: (view.height - 150) / 2,
                                    width: view.width - 50,
                                    height: 150)
    }
    
    // MARK: Actions
    
    @objc private func didTapCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Common
    
    private func configureViews() {
        tableView.delegate = self
        tableView.dataSource = self
        
        noAlbumsView.delegate = self
        noAlbumsView.configure(
            with: ActionLabelViewModel(
                text: "You don't have any saved albums yet.",
                actionTitle: "Browse"))
        
        view.addSubview(noAlbumsView)
        view.addSubview(tableView)
    }
    
    private func configureObserver() {
        observer = NotificationCenter.default.addObserver(
            forName: .albumSavedNotification,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                self?.fetchUserAlbums()
            })
    }
    
    private func updateUI() {
        if albums.isEmpty {
            noAlbumsView.isHidden = false
        } else {
            noAlbumsView.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
    
    private func fetchUserAlbums() {
        albums.removeAll()
        ApiManager.shared.getCurrentUserAlbums { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    self?.albums = model.items.compactMap({ $0.album })
                    self?.updateUI()
                case .failure(_):
                    break
                }
            }
        }
    }
    
}

// MARK: ActionLabelView Delegate

extension LibraryAlbumsViewController: ActionLabelViewDelegate {
    
    func actionLabelViewDidTapButton(_ actionView: ActionLabelView) {
        tabBarController?.selectedIndex = 0
    }
    
}

// MARK: TableView

extension LibraryAlbumsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultsSubtitleTableViewCell.identifier,
                                                 for: indexPath) as! SearchResultsSubtitleTableViewCell
        let album = albums[indexPath.row]
        cell.configure(with:
                        SearchResultsSubtitleTableViewCellViewModel(
                            title: album.name,
                            subtitle: album.artists.first?.name ?? " - ",
                            imageURL: URL(string: album.images.first?.url ?? "")))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        HapticsManager.shared.vibrateForSelection()
        
        let album = albums[indexPath.row]
        let albumVC = AlbumViewController(album: album)
        albumVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(albumVC, animated: true)
    }
}
