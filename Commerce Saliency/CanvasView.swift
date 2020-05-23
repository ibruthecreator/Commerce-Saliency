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
    var contentView: UIView = UIView() // Where all the actual content goes
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupViews() {
        addRoundedBorder()
    }
    
    @objc func tappedOutOfKeyboard(_ gesture: UITapGestureRecognizer) {
        guard let gestureView = gesture.view else {
            return
        }
        
        // If not a text view, hide keyboard
        if !(gestureView is UITextView) {
            hideKeyboard()
        }
    }
    
    func addRoundedBorder() {
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        
        addSubview(contentView)
        sendSubviewToBack(contentView)
        
        contentView.layer.cornerRadius = 0
        contentView.frame = self.bounds
        
        // Setup dashed border
        let dashedBorder = CAShapeLayer()
        dashedBorder.cornerRadius = 12
        dashedBorder.strokeColor = UIColor.black.withAlphaComponent(0.4).cgColor
        dashedBorder.lineDashPattern = [10, 10]
        dashedBorder.frame = contentView.bounds
        dashedBorder.fillColor = nil
        dashedBorder.path = UIBezierPath(rect: self.contentView.bounds).cgPath
        dashedBorder.lineCap = .round
        dashedBorder.lineJoin = .round
        dashedBorder.path = UIBezierPath(roundedRect: self.contentView.bounds, cornerRadius: 12).cgPath
        
        self.layer.addSublayer(dashedBorder)
    }
    
    /// Adds image to center of canvas
    /// - Parameter image: image to be added
    func addImage(image: UIImage) {
        // Remove all existing images
        for view in self.contentView.subviews {
            if view.isKind(of: UIImage.self) {
                view.removeFromSuperview()
            }
        }
        
        let imageView = UIImageView(frame: self.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        
        addGestureRecognizersToView(imageView)
    
        self.contentView.addSubview(imageView)
    }
    
    func addText(placeholder: String = "Edit this text", color: UIColor = .white) {
        let textView = UITextView()
        textView.text = placeholder
        textView.backgroundColor = UIColor.clear
        textView.textColor = color
        textView.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        textView.textAlignment = .center
        textView.sizeToFit()
        textView.delegate = self
        
        addGestureRecognizersToView(textView)
        
        self.contentView.addSubview(textView)
    }
    
    func clearCanvas() {
        for view in self.contentView.subviews {
            view.removeFromSuperview()
        }
        
        // Change bg back to white
        self.contentView.backgroundColor = UIColor.white
    }
    
    func changeBackgroundColor(to color: UIColor) {
        self.contentView.backgroundColor = color
    }
    
    func addGestureRecognizersToView(_ view: UIView) {
        // Assign a tag to the view based on the number of elements, then increment so no two views have the same tag
        view.isUserInteractionEnabled = true
        view.tag = numberOfElements
        numberOfElements += 1
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)))
        view.addGestureRecognizer(panGestureRecognizer)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchGesture(_:)))
        view.addGestureRecognizer(pinchGestureRecognizer)
        
        // If not a text view, and it's tapped hide keyboard
        if !(view is UITextView) {
            let hideKeyboardGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedOutOfKeyboard(_ :)))
            view.addGestureRecognizer(hideKeyboardGestureRecognizer)
        }
    }
    
    @objc func panGesture(_ gesture: UIPanGestureRecognizer) {
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
    
    @objc func pinchGesture(_ gesture: UIPinchGestureRecognizer) {
        // 1
        guard let gestureView = gesture.view else {
            return
        }
        
        if gesture.state == .began || gesture.state == .changed {
           gestureView.transform = (gestureView.transform.scaledBy(x: gesture.scale, y: gesture.scale))
           gesture.scale = 1.0
        }
    }
    
    func saveAsImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(contentView.bounds.size, contentView.isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            contentView.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        
        return nil
    }
    
    func hideKeyboard() {
        for view in self.contentView.subviews {
            if view is UITextView {
                view.resignFirstResponder()
            }
        }
    }
}

extension CanvasView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let newSize = textView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        textView.frame.size = CGSize(width: newSize.width, height: newSize.height)
    }
}
