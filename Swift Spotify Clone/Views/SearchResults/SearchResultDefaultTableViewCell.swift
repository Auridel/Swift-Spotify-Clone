//
//  SearchResultDefaultTableViewCell.swift
//  Swift Spotify Clone
//
//  Created by Олег Ефимов on 27.12.2021.
//

import UIKit
import SDWebImage

class SearchResultDefaultTableViewCell: UITableViewCell, TypedUITableViewCell {

    public static let identifier = "SearchResultDefaultTableViewCell"
    
    static let viewModelType = SearchResultDefaultTableViewCellViewModel.self
    
    private let label: UILabel = {
        let label = UILabel()
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
        contentView.addSubview(iconImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageSize = contentView.height - 10
        iconImageView.layer.masksToBounds = true
        iconImageView.layer.cornerRadius = imageSize / 2
        
        iconImageView.frame = CGRect(x: 10,
                                     y: 0,
                                     width: imageSize,
                                     height: imageSize)
        label.frame = CGRect(x: iconImageView.right + 10,
                             y: 0,
                             width: contentView.width - iconImageView.right - 15,
                             height: contentView.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        iconImageView.image = nil
        label.text = nil
    }
    
    public func configure(with viewModel: SearchResultDefaultTableViewCellViewModel) {
        label.text = viewModel.title
        iconImageView.sd_setImage(with: viewModel.imageURL, completed: nil)
    }
}
