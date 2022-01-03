//
//  SettingsViewController.swift
//  Swift Spotify Clone
//
//  Created by Олег Ефимов on 20.12.2021.
//

import UIKit

class SettingsViewController: UIViewController {
    
    private var sections = [Section]()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero,
                                    style: .grouped)
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Settings"
        view.backgroundColor = .systemBackground
        
        tableView.dataSource = self
        tableView.delegate = self
        configureModels()
        
        view.addSubview(tableView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
    }

    private func configureModels() {
        sections.append(Section(title: "Profile",
                                options: [
                                    Option(title: "View Your Profile",
                                           handler: { [weak self] in
                                               DispatchQueue.main.async {
                                                   self?.didTapViewProfile()
                                               }
                                           })
                                ]))
        sections.append(Section(title: "Account",
                                options: [
                                    Option(title: "Sign Out",
                                           handler: { [weak self] in
                                               DispatchQueue.main.async {
                                                   self?.didTapSignOut()
                                               }
                                           })
                                ]))
    }
    
    private func didTapViewProfile() {
        let profileVC = ProfileViewController()
        profileVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    private func didTapSignOut() {
        let alert = UIAlertController(title: "Sign Out",
                                      message: "Are you sure?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .cancel,
                                      handler: nil))
        alert.addAction(UIAlertAction(title: "Sign Out",
                                      style: .destructive,
                                      handler: { [weak self] _ in
            self?.signOut()
        }))
        
        present(alert, animated: true)
    }
    
    private func signOut() {
        AuthManager.shared.signOut { [weak self] isSuccess in
            DispatchQueue.main.async {
                let navVC = UINavigationController(rootViewController: WelcomeViewController())
                navVC.navigationBar.prefersLargeTitles = true
                navVC.viewControllers.first?.navigationItem.largeTitleDisplayMode = .always
                navVC.modalPresentationStyle = .fullScreen
                self?.present(navVC, animated: true) {
                    self?.navigationController?.popToRootViewController(animated: false)
                }
            }
        }
    }
}

// MARK: TableView Delegate

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].options.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = sections[indexPath.section].options[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = sections[indexPath.section].options[indexPath.row]
        model.handler()
    }
    
}
