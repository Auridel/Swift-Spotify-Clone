//
//  SearchResultsSubtitleTableViewCell.swift
//  Swift Spotify Clone
//
//  Created by Олег Ефимов on 28.12.2021.
//

import UIKit

class SearchResultsSubtitleTableViewCell: UITableViewCell, TypedUITableViewCell {
    
    public static let identifier = "SearchResultsSubtitleTableViewCell"
    
    static let viewModelType = SearchResultsSubtitleTableViewCellViewModel.self
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.clipsToBounds = true
        accessoryType = .disclosureIndicator
        
        contentView.addSubview(label)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(iconImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageSize = contentView.height - 10
        let labelHeight = contentView.height / 2
        
        iconImageView.frame = CGRect(x: 10,
                                     y: 0,
                                     width: imageSize,
                                     height: imageSize)
        label.frame = CGRect(x: iconImageView.right + 10,
                             y: 0,
                             width: contentView.width - iconImageView.right - 15,
                             height: labelHeight)
        subtitleLabel.frame = CGRect(x: iconImageView.right + 10,
                                     y: label.bottom,
                             width: contentView.width - iconImageView.right - 15,
                             height: labelHeight)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        iconImageView.image = nil
        label.text = nil
        subtitleLabel.text = nil
    }
    
    public func configure(with viewModel: SearchResultsSubtitleTableViewCellViewModel) {
        label.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        iconImageView.sd_setImage(with: viewModel.imageURL, completed: nil)
    }
}
