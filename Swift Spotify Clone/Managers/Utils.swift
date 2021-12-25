//
//  Utils.swift
//  Swift Spotify Clone
//
//  Created by Олег Ефимов on 25.12.2021.
//

import UIKit

class Utils {
    
    private init() {}
    
    public static func createComposeLayoutSection(itemLayoutSize: NSCollectionLayoutSize,
                                                  itemsInsets: NSDirectionalEdgeInsets,
                                                  verticalLayoutSize: NSCollectionLayoutSize,
                                                  horizontalLayoutSize: NSCollectionLayoutSize?,
                                                  verticalCount: Int,
                                                  horizontalCount: Int?,
                                                  orthogonalBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior?
    ) -> NSCollectionLayoutSection {
        //item
        let item = NSCollectionLayoutItem(layoutSize: itemLayoutSize)
        item.contentInsets = itemsInsets
        //vertical group in horizontal group
        
        let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: verticalLayoutSize,
                                                             subitem: item,
                                                             count: verticalCount)
        
        if let horizontalCount = horizontalCount, let horizontalLayoutSize = horizontalLayoutSize {
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: horizontalLayoutSize,
                                                                     subitem: verticalGroup,
                                                                     count: horizontalCount)
            //section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            if let orthogonalBehavior = orthogonalBehavior {
                section.orthogonalScrollingBehavior = orthogonalBehavior
            }
            return section
        }
        let section = NSCollectionLayoutSection(group: verticalGroup)
        if let orthogonalBehavior = orthogonalBehavior {
            section.orthogonalScrollingBehavior = orthogonalBehavior
        }
        return section
    }
}
