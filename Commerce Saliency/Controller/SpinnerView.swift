//
//  SpinnerView.swift
//  Commerce Saliency
//
//  Created by Mohammed Ibrahim on 2020-05-22.
//  Copyright © 2020 Mohammed Ibrahim. All rights reserved.
//

import UIKit

class SpinnerView: UIView {
    
    var spinner: UIActivityIndicatorView = UIActivityIndicatorView()
    var animationDuration: TimeInterval = 0.3
    
    var parentView: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupViews() {
        self.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
        self.clipsToBounds = true

        // Add blur view
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
        addSubview(blurView)
        
        blurView.frame = self.bounds
        
        // Set spinner style
        spinner.style = .large
        
        blurView.contentView.addSubview(spinner)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.centerYAnchor.constraint(equalTo: blurView.centerYAnchor).isActive = true
        spinner.centerXAnchor.constraint(equalTo: blurView.centerXAnchor).isActive = true
    }
    
    func hide() {
        spinner.stopAnimating()

        DispatchQueue.main.async {
            UIView.animate(withDuration: self.animationDuration) {
                self.removeFromSuperview()
            }
        }
    }
    
    func show() {
        spinner.startAnimating()
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: self.animationDuration) {
                self.parentView?.addSubview(self)
            }
        }
    }
    
    func centerAndSetSize(withHeight height: CGFloat, withWidth width: CGFloat) {
        if let parentWidth = self.parentView?.bounds.width, let parentHeight = self.parentView?.bounds.height {
            let xPosition = (parentWidth / 2) - (width / 2)
            let yPosition = (parentHeight / 2) - (height / 2)
            
            self.frame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
        }
    }
}
