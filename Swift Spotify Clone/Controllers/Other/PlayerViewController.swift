//
//  PlayerViewController.swift
//  Swift Spotify Clone
//
//  Created by Олег Ефимов on 20.12.2021.
//

import UIKit
import SDWebImage

protocol PlayerViewControllerDelegate: AnyObject {
    func didTapPlayPause()
    func didTapForward()
    func didTapBackward()
    func didUpdateSlider(_ value: Float)
}

class PlayerViewController: UIViewController {
    
    weak var dataSource: PlayerDataSource?
    
    weak var delegate: PlayerViewControllerDelegate?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .systemBlue
        return imageView
    }()
    
    private let controlsView = PlayerControlsView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
        configureBarButtons()
        configureViews()
        configureDataSource()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imageView.frame = CGRect(x: 0,
                                 y: view.safeAreaInsets.top,
                                 width: view.width,
                                 height: view.width)
        controlsView.frame = CGRect(
            x: 10,
            y: imageView.bottom + 10,
            width: view.width - 20,
            height: view.height - imageView.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom - 15)
    }
    
    // MARK: Actions
    
    @objc private func didTapCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapActionButton() {
        //open actionsheet
    }
    
    // MARK: Common
    
    private func configureViews() {
        controlsView.delegate = self
        
        view.addSubview(imageView)
        view.addSubview(controlsView)
    }
    
    private func configureBarButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                           target: self,
                                                           action: #selector(didTapCloseButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action,
                                                           target: self,
                                                           action: #selector(didTapActionButton))
    }
    
    private func configureDataSource() {
        imageView.sd_setImage(with: dataSource?.imageURL,
                              completed: nil)
        controlsView.configure(with: PlayerControlsViewViewModel(
            title: dataSource?.songName,
            subtitle: dataSource?.subtitle))
    }
}

// MARK: PlayerControls Delegate

extension PlayerViewController: PlayerControlsViewDelegate {
    
    func playerControlsViewDidInteractSlider(_ playerControlsView: PlayerControlsView, didInteractSlider value: Float) {
        delegate?.didUpdateSlider(value)
    }
    
    func playerControlsViewDidTapPlayPause(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapPlayPause()
    }
    
    func playerControlsViewDidTapForwardButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapForward()
    }
    
    func playerControlsViewDidTapBackwardsButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapBackward()
    }
    
}
