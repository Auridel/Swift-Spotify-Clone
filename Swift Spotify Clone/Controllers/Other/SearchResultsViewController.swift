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
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",
                                                 for: indexPath)
        switch model {
        case .artist(model: let model):
            cell.textLabel?.text = model.name
        case .album(model: let model):
            cell.textLabel?.text = model.name
        case .playlist(model: let model):
            cell.textLabel?.text = model.name
        case .track(model: let model):
            cell.textLabel?.text = model.name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let result = sections[indexPath.section].results[indexPath.row]
        delegate?.didTapSearchResult(result)
    }
    
}
