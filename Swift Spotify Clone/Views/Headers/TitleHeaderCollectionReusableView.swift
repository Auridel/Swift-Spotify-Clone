//
//  TitleHeaderCollectionReusableView.swift
//  Swift Spotify Clone
//
//  Created by Олег Ефимов on 25.12.2021.
//

import UIKit

class TitleHeaderCollectionReusableView: UICollectionReusableView {
        
    public static let identifier = "TitleHeaderCollectionReusableView"
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 22, weight: .light)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemBackground
        
        addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        label.frame = CGRect(x: 15,
                             y: 0,
                             width: width - 30,
                             height: height)
    }
    
    public func configure(with title: String) {
        label.text = title
    }
}
