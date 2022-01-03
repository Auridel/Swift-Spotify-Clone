//
//  WelcomeViewController.swift
//  Swift Spotify Clone
//
//  Created by Олег Ефимов on 20.12.2021.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "albums_cover")
        return imageView
    }()
    
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.alpha = 0.7
        return view
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo_transparent")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let logoLabel: UILabel = {
        let label = UILabel()
        label.text = "Listen to Millions\nof Songs on the go"
        label.numberOfLines = 0
        label.textColor = .label
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 32, weight: .semibold)
        return label
    }()
    
    private let signInButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("Sign In With Spotify",
                        for: .normal)
        button.setTitleColor(.black,
                             for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Spotify"
        view.backgroundColor = .systemBackground
        
        signInButton.addTarget(self,
                               action: #selector(didTapSignIn),
                               for: .touchUpInside)
        view.addSubview(backgroundImageView)
        view.addSubview(overlayView)
        view.addSubview(logoImageView)
        view.addSubview(logoLabel)
        view.addSubview(signInButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        backgroundImageView.frame = view.bounds
        overlayView.frame = view.bounds
        signInButton.frame = CGRect(
            x: 20,
            y: view.height - 50 - view.safeAreaInsets.bottom,
            width: view.width - 40,
            height: 50)
        logoImageView.frame = CGRect(
            x: (view.width - 120) / 2,
            y: (view.height - 200) / 2,
            width: 120,
            height: 120)
        logoLabel.frame = CGRect(
            x: 30,
            y: logoImageView.bottom + 30,
            width: view.width - 60,
            height: 150)
        
    }
    
    //MARK: Action
    
    @objc private func didTapSignIn() {
        let authVC = AuthViewController()
        authVC.completionHandler = { [weak self] isSuccess in
            DispatchQueue.main.async {
                self?.handleSignIn(success: isSuccess)
            }
        }
        authVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(authVC, animated: true)
    }
    
    // MARK: Common

    private func handleSignIn(success: Bool) {
        guard success else {
            let alert = UIAlertController(title: "Oops!",
                                          message: "Something went wrong...",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok",
                                          style: .cancel,
                                          handler: nil))
            present(alert, animated: true)
            return
        }
        let mainAppTabBarVC = TabBarViewController()
        mainAppTabBarVC.modalPresentationStyle = .fullScreen
        present(mainAppTabBarVC, animated: true)
    }
}
