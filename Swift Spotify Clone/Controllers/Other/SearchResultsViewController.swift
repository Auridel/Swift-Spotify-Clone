//
//  SearchResultsViewController.swift
//  Swift Spotify Clone
//
//  Created by Олег Ефимов on 20.12.2021.
//

import UIKit

protocol SearchResultsViewControllerDelegate: AnyObject {
    func didTapSearchResult(_ result: SearchResult)
}

class SearchResultsViewController: UIViewController {
    
    private var sections = [SearchSection]()
    
    weak var delegate: SearchResultsViewControllerDelegate?
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero,
                                    style: .grouped)
        tableView.register(SearchResultDefaultTableViewCell.self,
                           forCellReuseIdentifier: SearchResultDefaultTableViewCell.identifier)
        tableView.register(SearchResultsSubtitleTableViewCell.self,
                           forCellReuseIdentifier: SearchResultsSubtitleTableViewCell.identifier)
        tableView.isHidden = true
        tableView.backgroundColor = .systemBackground
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        
        configureViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
    }
    
    /// updates tableview with search results
    public func update(with results: [SearchResult]) {
        var filtredResults = FiltredSearchResults(
            artists: [],
            albums: [],
            tracks: [],
            playlists: [])
        for result in results {
            switch result {
            case .artist:
                filtredResults.artists.append(result)
            case .album:
                filtredResults.albums.append(result)
            case .playlist:
                filtredResults.playlists.append(result)
            case .track:
                filtredResults.tracks.append(result)
            }
        }
        self.sections = [
            SearchSection(title: "Tracks", results: filtredResults.tracks),
            SearchSection(title: "Artists", results: filtredResults.artists),
            SearchSection(title: "Playlists", results: filtredResults.playlists),
            SearchSection(title: "Albums", results: filtredResults.albums)
        ]
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.isHidden = results.isEmpty
        }
    }

    // MARK: Common
    
    private func configureViews() {
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
    }
    
    private func configureTableViewCell<T>(with viewModel: T, indexPath: IndexPath) -> UITableViewCell {
        switch viewModel.self {
        case is SearchResultDefaultTableViewCellViewModel:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultDefaultTableViewCell.identifier,
                                                     for: indexPath) as? SearchResultDefaultTableViewCell,
                  let viewModel = viewModel as? SearchResultDefaultTableViewCellViewModel
            else {
                return UITableViewCell()
            }
            cell.configure(with: viewModel)
            return cell
        case is SearchResultsSubtitleTableViewCellViewModel:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultsSubtitleTableViewCell.identifier,
                                                     for: indexPath) as? SearchResultsSubtitleTableViewCell,
                  let viewModel = viewModel as? SearchResultsSubtitleTableViewCellViewModel
            else {
                return UITableViewCell()
            }
            cell.configure(with: viewModel)
            return cell
        default:
            return UITableViewCell()
        }
    }
}


// MARK: TableView

extension SearchResultsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].results.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = sections[indexPath.section].results[indexPath.row]
        
        switch model {
        case .artist(model: let artist):
            return configureTableViewCell(
                with: SearchResultDefaultTableViewCellViewModel(
                    title: artist.name,
                    imageURL: URL(string: artist.images?.first?.url ?? "")),
                indexPath: indexPath)
        case .album(model: let album):
            return configureTableViewCell(
                with: SearchResultsSubtitleTableViewCellViewModel(
                    title: album.name,
                    subtitle: album.artists.first?.name ?? "",
                    imageURL: URL(string: album.images.first?.url ?? "")),
                indexPath: indexPath)
        case .playlist(model: let playlist):
            return configureTableViewCell(
                with: SearchResultsSubtitleTableViewCellViewModel(
                    title: playlist.name,
                    subtitle: playlist.owner.display_name,
                    imageURL: URL(string: playlist.images.first?.url ?? "")),
                indexPath: indexPath)
        case .track(model: let track):
            return configureTableViewCell(
                with: SearchResultsSubtitleTableViewCellViewModel(
                    title: track.name,
                    subtitle: track.artists.first?.name ?? "",
                    imageURL: URL(string: track.album?.images.first?.url ?? "")),
                indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let result = sections[indexPath.section].results[indexPath.row]
        delegate?.didTapSearchResult(result)
    }
    
}
