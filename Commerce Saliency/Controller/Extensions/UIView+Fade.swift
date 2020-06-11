//
//  UIView+Fade.swift
//  Commerce Saliency
//
//  Created by Mohammed Ibrahim on 2020-06-10.
//  Copyright © 2020 Mohammed Ibrahim. All rights reserved.
//

import UIKit

extension UIView {
    /// Fade out any UIView with an animated duration
    /// - Parameter duration: duration of animation (in seconds)
    func fadeOut(withDuration duration: TimeInterval = 0.3) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: duration) {
                self.alpha = 0.0
            }
        }
    }
    
    /// Fade in any UIView with an animated duration
    /// - Parameter duration: duration of animation (in seconds)
    func fadeIn(withDuration duration: TimeInterval = 0.3) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: duration) {
                self.alpha = 1.0
            }
        }
    }
}
