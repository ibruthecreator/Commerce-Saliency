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
    
    // Temporary text view transform variable
    var currentTextViewTransform: CGAffineTransform?
    var currentFontSize: CGFloat = 26
    var originalTextSize: CGFloat = 26
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupViews() {
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        
        addSubview(contentView)
        sendSubviewToBack(contentView)
        
        // Set constraints
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        contentView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        contentView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        
        self.layoutSubviews()
        self.contentView.layoutSubviews()
        
        // Setup dashed border
        let dashedBorder = CAShapeLayer()
        dashedBorder.cornerRadius = 12
        dashedBorder.strokeColor = UIColor.black.withAlphaComponent(0.4).cgColor
        dashedBorder.lineDashPattern = [10, 10]
        dashedBorder.frame = self.bounds
        dashedBorder.fillColor = nil
        dashedBorder.lineCap = .round
        dashedBorder.lineJoin = .round
        dashedBorder.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: 12).cgPath

        self.layer.addSublayer(dashedBorder)
    }
    
    // Tap gesture for out of keyboard
    @objc func tappedOutOfKeyboard(_ gesture: UITapGestureRecognizer) {
        guard let gestureView = gesture.view else {
            return
        }
        
        // If not tapped on a text view, hide keyboard
        if !(gestureView is UITextView) {
            hideKeyboard()
        }
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
        
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 500, height: 500)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        imageView.center = self.center
        
        addGestureRecognizersToView(imageView)
        self.contentView.addSubview(imageView)
    }
    
    /// Add text to canvas view
    /// - Parameters:
    ///   - placeholder: Placeholder text
    ///   - color: Color of text
    func addText(placeholder: String = "Edit this text", color: UIColor = .white) {
        let textView = UITextView()
        textView.text = placeholder
        textView.backgroundColor = UIColor.clear
        textView.textColor = color
        textView.font = UIFont(name: "CircularStd-Bold", size: originalTextSize)
        textView.textAlignment = .center
        textView.sizeToFit()
        textView.center = self.contentView.center
        textView.delegate = self
        
        addGestureRecognizersToView(textView)
        
        self.contentView.addSubview(textView)
        
        textView.becomeFirstResponder()
    }
    
    /// Clear all elements of canvas and make background white
    func clearCanvas() {
        for view in self.contentView.subviews {
            view.removeFromSuperview()
        }
        
        // Change bg back to white
        self.contentView.backgroundColor = UIColor.white
    }
    
    /// Change background color
    /// - Parameter color: color to change background to
    func changeBackgroundColor(to color: UIColor) {
        self.contentView.backgroundColor = color
    }
    
    func addGestureRecognizersToView(_ view: UIView) {
        // Assign a tag to the view based on the number of elements, then increment so no two views have the same tag
        view.isUserInteractionEnabled = true
        view.isMultipleTouchEnabled = true
        
        view.tag = numberOfElements
        numberOfElements += 1
        
        // Pan Gesture Recognizer for moving a node around
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)))
        view.addGestureRecognizer(panGestureRecognizer)
        
        // Pinch Gesture Recognizer for scaling up or down a node
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchGesture(_:)))
        view.addGestureRecognizer(pinchGestureRecognizer)
        
        // Rotate Gesture Recognizer for rotating a node CW or CCW
        let rotateGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotateGesture(_:)))
        view.addGestureRecognizer(rotateGestureRecognizer)
        
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
        // Slightly different logic for a UITextView as the fonts have to be scaled too
        if let textView = gesture.view as? UITextView {
            self.currentTextViewTransform = textView.transform
            textView.transform = .identity
            
            if gesture.state == .began {
                gesture.scale = textView.font!.pointSize * 0.1
            }
            if 1 <= gesture.scale && gesture.scale <= 10  {
                textView.font = UIFont(name: "CircularStd-Bold", size: gesture.scale * 10)

                textViewDidChange(textView)
            }
            
            textView.transform = self.currentTextViewTransform ?? .identity
        } else if let gestureView = gesture.view {
            if gesture.state == .began || gesture.state == .changed {
               gestureView.transform = (gestureView.transform.scaledBy(x: gesture.scale, y: gesture.scale))
               gesture.scale = 1.0
            }
        }
    }
    
    @objc func rotateGesture(_ gesture: UIRotationGestureRecognizer) {
        guard let gestureView = gesture.view else {
            return
        }
        
        if gesture.state == .began || gesture.state == .changed {
            gestureView.transform = gestureView.transform.rotated(by: gesture.rotation)
            gesture.rotation = 0
        }
    }
    
    /// Creates an image from the content view, clipping everything outside of the canvas
    /// - Returns: Resulting image
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

// MARK: - UITextViewDelegate
extension CanvasView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        let transform = textView.transform
        self.currentTextViewTransform = transform
        self.currentFontSize = textView.font?.pointSize ?? 22
        
        UIView.animate(withDuration: 0.3) {
            textView.font = UIFont(name: "CircularStd-Bold", size: self.originalTextSize)
            textView.transform = .identity  // Revert to origin temporarily for better editing UX
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let currentTransform = self.currentTextViewTransform {
            UIView.animate(withDuration: 0.3) {
                textView.font = UIFont(name: "CircularStd-Bold", size: self.currentFontSize)
                textView.transform = currentTransform
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let newSize = textView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        textView.frame.size = CGSize(width: newSize.width, height: newSize.height)
    }
}
