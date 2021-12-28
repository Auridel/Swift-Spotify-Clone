//
//  PlayerControlsView.swift
//  Swift Spotify Clone
//
//  Created by Олег Ефимов on 28.12.2021.
//

import UIKit

protocol PlayerControlsViewDelegate: AnyObject {
    func playerControlsViewDidTapPlayPause(_ playerControlsView: PlayerControlsView)
    func playerControlsViewDidTapForwardButton(_ playerControlsView: PlayerControlsView)
    func playerControlsViewDidTapBackwardsButton(_ playerControlsView: PlayerControlsView)
}

class PlayerControlsView: UIView {
    
    weak var delegate: PlayerControlsViewDelegate?
    
    private let volumeSlider: UISlider = {
        let slider = UISlider()
        slider.value = 0.5
        return slider
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        button.setImage(
            UIImage(
                systemName: "backward.fill",
                withConfiguration: UIImage.SymbolConfiguration(
                    pointSize: 34,
                    weight: .regular)),
            for: .normal)
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        button.setImage(
            UIImage(
                systemName: "forward.fill",
                withConfiguration: UIImage.SymbolConfiguration(
                    pointSize: 34,
                    weight: .regular)),
            for: .normal)
        return button
    }()
    
    private let playPauseButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        button.setImage(
            UIImage(
                systemName: "pause",
                withConfiguration: UIImage.SymbolConfiguration(
                    pointSize: 34,
                    weight: .regular)),
            for: .normal)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setSubviewsFrames()
    }
    
    // MARK: Actions
    
    @objc private func didTapPlayPauseButton() {
        delegate?.playerControlsViewDidTapPlayPause(self)
    }
    
    @objc private func didTapBackButton() {
        delegate?.playerControlsViewDidTapBackwardsButton(self)
    }
    
    @objc private func didTapNextButton() {
        delegate?.playerControlsViewDidTapForwardButton(self)
    }
    
    // MARK: Common
    
    private func configureViews() {
        backButton.addTarget(self,
                             action: #selector(didTapBackButton),
                             for: .touchUpInside)
        nextButton.addTarget(self,
                             action: #selector(didTapNextButton),
                             for: .touchUpInside)
        playPauseButton.addTarget(self,
                                  action: #selector(didTapPlayPauseButton),
                                  for: .touchUpInside)
        
        addSubview(nameLabel)
        addSubview(subtitleLabel)
        addSubview(volumeSlider)
        addSubview(backButton)
        addSubview(nextButton)
        addSubview(playPauseButton)
    }
    
    private func setSubviewsFrames() {
        let buttonSize: CGFloat = 60
        
        nameLabel.frame = CGRect(x: 0,
                                 y: 0,
                                 width: width,
                                 height: 50)
        subtitleLabel.frame = CGRect(x: 0,
                                     y: nameLabel.bottom + 10,
                                 width: width,
                                 height: 50)
        volumeSlider.frame = CGRect(x: 10,
                                    y: subtitleLabel.bottom + 20,
                                    width: width - 20,
                                    height: 44)
        playPauseButton.frame = CGRect(x: width / 2 - buttonSize / 2,
                                       y: volumeSlider.bottom + 30,
                                       width: buttonSize,
                                       height: buttonSize)
        backButton.frame = CGRect(x: 20,
                                  y: playPauseButton.top,
                                  width: buttonSize,
                                  height: buttonSize)
        nextButton.frame = CGRect(x: width - 20 - buttonSize,
                                  y: playPauseButton.top,
                                  width: buttonSize,
                                  height: buttonSize)
    }
}
