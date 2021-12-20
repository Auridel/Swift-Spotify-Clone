//
//  WelcomeViewController.swift
//  Swift Spotify Clone
//
//  Created by Олег Ефимов on 20.12.2021.
//

import UIKit

class WelcomeViewController: UIViewController {
    
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
        view.backgroundColor = .systemGreen
        
        signInButton.addTarget(self,
                               action: #selector(didTapSignIn),
                               for: .touchUpInside)
        view.addSubview(signInButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        signInButton.frame = CGRect(x: 20,
                                    y: view.height - 50 - view.safeAreaInsets.bottom,
                                    width: view.width - 40,
                                    height: 50)
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
