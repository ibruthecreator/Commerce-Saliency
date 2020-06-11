//
//  ViewController.swift
//  Commerce Saliency
//
//  Created by Mohammed Ibrahim on 2020-05-18.
//  Copyright © 2020 Mohammed Ibrahim. All rights reserved.
//

import UIKit
import Alamofire
import ColorSlider
import Toucan

class ViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var clearCanvasButton: UIButton!
    @IBOutlet weak var exportCanvasButton: UIButton!
    
    @IBOutlet weak var canvasView: CanvasView!
    @IBOutlet weak var toolbarView: ToolbarView!
    
    var backgroundColorView: UIView = UIView()
    
    var originalImage: UIImage?
    var maskedImage: UIImage?
    var picker = UIImagePickerController()
    var spinner: UIActivityIndicatorView = UIActivityIndicatorView(style: .large)
    
    let colorSlider = ColorSlider(orientation: .vertical, previewSide: .left)
    
    // MARK: - Variables
    let colorPickerHeight = 200
    let colorPickerWidth = 15
    
    var colorPickerHidden = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        setupViews()
    }
    
    // MARK: - Setup Views
    func setupViews() {
        picker.delegate = self
        
        clearCanvasButton.layer.cornerRadius = 8
        exportCanvasButton.layer.cornerRadius = 8
        
        // Toolbar View
        toolbarView.layer.cornerRadius = 12
        toolbarView.layer.shadowColor = UIColor.black.cgColor
        toolbarView.layer.shadowRadius = 12
        toolbarView.layer.shadowOpacity = 0.10
        toolbarView.layer.shadowOffset = CGSize(width: 0, height: 5)
        
        toolbarView.delegate = self
        
        // Canvas View
        canvasView.layer.shadowColor = UIColor.black.cgColor
        canvasView.layer.shadowRadius = 12
        canvasView.layer.shadowOpacity = 0.10
        canvasView.layer.shadowOffset = CGSize(width: 0, height: 5)
        
        canvasView.layer.cornerRadius = 12
        canvasView.isUserInteractionEnabled = true
            
        // Color Slider
        colorSlider.frame = CGRect(x: Int(canvasView.frame.maxX) - colorPickerWidth - 10, y: Int(canvasView.frame.minY) + 10, width: colorPickerWidth, height: colorPickerHeight)
        colorSlider.addTarget(self, action: #selector(colorDidChangeValue(_: )), for: .valueChanged)
        colorSlider.gradientView.layer.borderWidth = 2.0
        colorSlider.gradientView.layer.borderColor = UIColor.white.cgColor
        
        // Should have a hidden state at first
        colorSlider.alpha = 0.0
        colorSlider.isUserInteractionEnabled = false
        
        view.addSubview(colorSlider)
        
        // Loading Spinner
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.alpha = 0.0

        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        // Tap Out Of View Gesture Recognizer
        let hideKeyboardGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedOutOfKeyboard(_ :)))
        self.view.addGestureRecognizer(hideKeyboardGestureRecognizer)
        
        
        // Background View
        self.view.addSubview(backgroundColorView)
        
        backgroundColorView.translatesAutoresizingMaskIntoConstraints = false
        backgroundColorView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        backgroundColorView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        backgroundColorView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        backgroundColorView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        self.backgroundColorView.addGestureRecognizer(hideKeyboardGestureRecognizer)
        self.view.sendSubviewToBack(backgroundColorView)
        
        backgroundColorView.backgroundColor = self.canvasView.contentView.backgroundColor
        
        toolbarView.loadTools()
        canvasView.setupViews()
    }
    
    /// Tap gesture to resign first responder
    @objc func tappedOutOfKeyboard(_ gesture: UITapGestureRecognizer) {
        canvasView.hideKeyboard()
    }
    
    /// Clear canvas view action
    @IBAction func clearCanvas(_ sender: Any) {
        canvasView.clearCanvas()
        backgroundColorView.backgroundColor = self.canvasView.contentView.backgroundColor
    }
    
    /// Export image action
    @IBAction func exportImage(_ sender: Any) {
        if let canvasExport = canvasView.saveAsImage() {
            UIImageWriteToSavedPhotosAlbum(canvasExport, nil, nil, nil)
        }
    }

    @objc func colorDidChangeValue(_ slider: ColorSlider) {
        let color = slider.color
        canvasView.changeBackgroundColor(to: color)
        self.backgroundColorView.backgroundColor = color.withAlphaComponent(0.5)
    }
    
    /// Hide or remove the color slider
    func addRemoveColorPicker() {
        DispatchQueue.main.async {
            if self.colorPickerHidden {
                self.colorSlider.isUserInteractionEnabled = false
                self.colorSlider.fadeOut()
            } else {
                self.colorSlider.isUserInteractionEnabled = true
                self.colorSlider.fadeIn()
            }
        }
        
        colorPickerHidden = !colorPickerHidden
    }
}

// MARK: - ToolBarDelegate
extension ViewController: ToolBarDelegate {
    func didClickAddImageButton() {
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    func didClickColorWheel() {
        addRemoveColorPicker()
    }
    
    func didClickAddTextButton() {
        canvasView.addText()
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Cropped image
        guard let image = info[.editedImage] as? UIImage else {
            self.picker.dismiss(animated: true, completion: nil)
            fatalError("Failed to fetch image")
        }
        
        // Show spinner and start animating
        self.spinner.alpha = 1.0
        self.spinner.startAnimating()
        
        self.picker.dismiss(animated: true, completion: nil)
        
        // Upload image
        APIController.sharedInstance.uploadImage(image) { (success, maskImage) in
            self.spinner.alpha = 0
            self.spinner.stopAnimating()
            
            if success && maskImage != nil {
                // Create final image using the original image and the mask returned from the API request
                if let toucanImage = Toucan(image: image).maskWithImage(maskImage: maskImage!).image {
                    self.maskedImage = toucanImage
                    self.canvasView.addImage(image: toucanImage)
                }
            }
        }
    }
}
