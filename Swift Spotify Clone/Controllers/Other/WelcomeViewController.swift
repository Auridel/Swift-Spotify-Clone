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
                self?.hanleSignIn(success: isSuccess)
            }
        }
        authVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(authVC, animated: true)
    }
    
    // MARK: Common

    private func hanleSignIn(success: Bool) {
        
    }
}
