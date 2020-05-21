//
//  CanvasView.swift
//  Commerce Saliency
//
//  Created by Mohammed Ibrahim on 2020-05-20.
//  Copyright © 2020 Mohammed Ibrahim. All rights reserved.
//

import UIKit

class CanvasView: UIView {
    var numberOfElements = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupViews() {
        addRoundedBorder()
    }
    
    func loadPlaceholder() {
        
    }
    
    func addRoundedBorder() {
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        
        // Setup dashed border
        let dashedBorder = CAShapeLayer()
        dashedBorder.cornerRadius = 12
        dashedBorder.strokeColor = UIColor.black.withAlphaComponent(0.4).cgColor
        dashedBorder.lineDashPattern = [10, 10]
        dashedBorder.frame = self.bounds
        dashedBorder.fillColor = nil
        dashedBorder.path = UIBezierPath(rect: self.self.bounds).cgPath
        dashedBorder.lineCap = .round
        dashedBorder.lineJoin = .round
        dashedBorder.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: 12).cgPath
        
        self.layer.addSublayer(dashedBorder)
    }
    
    /// Adds image to center of canvas
    /// - Parameter image: image to be added
    func addImage(image: UIImage) {
        // Remove all existing images
        for view in self.subviews {
            if view.isKind(of: UIImage.self) {
                view.removeFromSuperview()
            }
        }
        
        let imageView = UIImageView(frame: self.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        
        addGestureRecognizerToView(imageView)
    
        self.addSubview(imageView)
    }
    
    func clearCanvas() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
    }
    
    func changeBackgroundColor(to color: UIColor) {
        self.backgroundColor = color
    }
    
    func addGestureRecognizerToView(_ view: UIView) {
        // Assign a tag to the view based on the number of elements, then increment so no two views have the same tag
        view.isUserInteractionEnabled = true
        view.tag = numberOfElements
        numberOfElements += 1
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)))
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func panGesture(_ gesture: UIPanGestureRecognizer) {
        // Make sure tag exists
        /*if let tag = gesture.view?.tag {
            // Make sure view with tag exists
            if let draggingView = self.viewWithTag(tag) {
                switch gesture.state {
                    case .changed:
                        draggingView.center = gesture.location(in: self)
                    default:
                        return
                }
            }
        }*/
        // 1
        let translation = gesture.translation(in: self)

        // 2
        guard let gestureView = gesture.view else {
          return
        }

        gestureView.center = CGPoint(
          x: gestureView.center.x + translation.x,
          y: gestureView.center.y + translation.y
        )

        // 3
        gesture.setTranslation(.zero, in: self)
    }
    
    func saveAsImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            self.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        return nil
    }
}
