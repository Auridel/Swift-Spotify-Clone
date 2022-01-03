//
//  HapticsManager.swift
//  Swift Spotify Clone
//
//  Created by Олег Ефимов on 20.12.2021.
//

import UIKit

final class HapticsManager {
    
    public static let shared = HapticsManager()
    
    private init() {}
    
    public func vibrateForSelection() {
        DispatchQueue.main.async {
            let generatior = UISelectionFeedbackGenerator()
            generatior.prepare()
            generatior.selectionChanged()
        }
    }
    
    public func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType) {
        DispatchQueue.main.async {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(type)
        }
    }
}
