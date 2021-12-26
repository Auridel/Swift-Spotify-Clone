//
//  GenreCollectionViewCell.swift
//  Swift Spotify Clone
//
//  Created by Олег Ефимов on 26.12.2021.
//

import UIKit

class GenreCollectionViewCell: UICollectionViewCell {
    
    public static let identifier = "GenreCollectionViewCell"
    
    private let colors: [UIColor] = [
        .systemPurple, .systemGreen, .systemBlue, .systemOrange, .systemPink, .systemRed, .systemYellow, .systemGray, .systemBrown, .systemIndigo
    ]
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.image = UIImage(
            systemName: "music.quarternote.3",
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: 50,
                weight: .regular))
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(imageView)
        contentView.addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        label.frame = CGRect(x: 10,
                             y: contentView.height / 2,
                             width: width,
                             height: contentView.height / 2)
        imageView.frame = CGRect(x: contentView.width / 2,
                                 y: 0,
                                 width: contentView.width / 2,
                                 height: contentView.height / 2)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        label.text = nil
    }
    
    // MARK: Common
    
    public func configure(with title: String) {
        label.text = title
        contentView.backgroundColor = colors.randomElement()
    }
}
