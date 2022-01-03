//
//  LibraryPlaylistsViewController.swift
//  Swift Spotify Clone
//
//  Created by Олег Ефимов on 29.12.2021.
//

import UIKit

class LibraryPlaylistsViewController: UIViewController {
    
    public var selectionHandler: ((Playlist) -> Void)?
    
    private var playlists = [Playlist]()
    
    private let noPlaylistsView = ActionLabelView()
    
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
        fetchUserPlaylists()
        
        if selectionHandler != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                             target: self,
                                                             action: #selector(didTapCloseButton))
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
        noPlaylistsView.frame = CGRect(x: 0,
                                       y: 0,
                                       width: view.width - 20,
                                       height: 150)
        noPlaylistsView.center = view.center
    }
    
    // MARK: Actions
    
    @objc private func didTapCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Common
    
    public func showCreatePlaylistAlert() {
        let alert = UIAlertController(
            title: "New Playlist",
            message: "Enter Playlist Name",
            preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Playlist..."
        }
        
        alert.addAction(
            UIAlertAction(title: "Cancel",
                          style: .cancel,
                          handler: nil))
        alert.addAction(
            UIAlertAction(title: "Create",
                          style: .default,
                          handler: { _ in
                              guard let textField = alert.textFields?.first,
                                    let text = textField.text,
                                    !text.trimmingCharacters(in: .whitespaces).isEmpty
                              else { return }
                              ApiManager.shared.createPlaylist(with: text) { [weak self] result in
                                  switch result {
                                  case .success(let playlist):
                                      self?.playlists.insert(playlist, at: 0)
                                  case .failure(let error):
                                      print("Failed to create playlist \(error)")
                                  }
                              }
                          }))
        
        present(alert, animated: true)
    }
    
    private func configureViews() {
        tableView.delegate = self
        tableView.dataSource = self
        
        noPlaylistsView.delegate = self
        noPlaylistsView.configure(
            with: ActionLabelViewModel(
                text: "You don't have any playlists yet.",
                actionTitle: "Create"))
        
        view.addSubview(noPlaylistsView)
        view.addSubview(tableView)
    }
    
    private func updateUI() {
        if playlists.isEmpty {
            noPlaylistsView.isHidden = false
        } else {
            noPlaylistsView.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
    
    private func fetchUserPlaylists() {
        ApiManager.shared.getCurrentUserPlaylists { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    self?.playlists = model.items
                    self?.updateUI()
                case .failure(_):
                    break
                }
            }
        }
    }
    
}

// MARK: ActionLabelView Delegate

extension LibraryPlaylistsViewController: ActionLabelViewDelegate {
    
    func actionLabelViewDidTapButton(_ actionView: ActionLabelView) {
        showCreatePlaylistAlert()
    }
    
}

// MARK: TableView

extension LibraryPlaylistsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultsSubtitleTableViewCell.identifier,
                                                 for: indexPath) as! SearchResultsSubtitleTableViewCell
        let playlist = playlists[indexPath.row]
        cell.configure(with:
                        SearchResultsSubtitleTableViewCellViewModel(
                            title: playlist.name,
                            subtitle: playlist.description ?? "",
                            imageURL: URL(string: playlist.images.first?.url ?? "")))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let playlist = playlists[indexPath.row]
        guard selectionHandler == nil else {
            selectionHandler?(playlist)
            dismiss(animated: true, completion: nil)
            return
        }
        let playlistVC = PlaylistViewController(playlist: playlist)
        playlistVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(playlistVC, animated: true)
    }
}
