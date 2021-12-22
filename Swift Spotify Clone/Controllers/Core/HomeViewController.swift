//
//  ViewController.swift
//  Swift Spotify Clone
//
//  Created by Олег Ефимов on 19.12.2021.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapSettings))
        
        fetchData()
    }

    // MARK: Actions

    @objc private func didTapSettings() {
        let settingsVC = SettingsViewController()
        settingsVC.title = "Settings"
        settingsVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    // MARK: Common
    
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

