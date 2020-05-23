//
//  ViewController.swift
//  Commerce Saliency
//
//  Created by Mohammed Ibrahim on 2020-05-18.
//  Copyright © 2020 Mohammed Ibrahim. All rights reserved.
//

import UIKit
import Alamofire
import ChromaColorPicker
import Toucan

class ViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var clearCanvasButton: UIButton!
    @IBOutlet weak var exportCanvasButton: UIButton!
    
    @IBOutlet weak var canvasView: CanvasView!
    @IBOutlet weak var toolbarView: ToolbarView!
    
    var colorPickerHidden = true
    
    var colorPicker = ChromaColorPicker(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
    var brightnessSlider = ChromaBrightnessSlider(frame: CGRect(x: 0, y: 0, width: 130, height: 32))
        
    var originalImage: UIImage?
    var maskedImage: UIImage?
    var picker = UIImagePickerController()
    var spinner: UIActivityIndicatorView = UIActivityIndicatorView(style: .large)
    
    // MARK: - Variables
    let colorPickerHeight = 150
    let colorPickerWidth = 150
    let brightnessSliderHeight = 32
    let brightnessSliderWidth = 130
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        // Do any additional setup after loading the view.
    }

    // MARK: - Setup Views
    func setupViews() {
        picker.delegate = self
        
        clearCanvasButton.layer.cornerRadius = 8
        exportCanvasButton.layer.cornerRadius = 8
        
        toolbarView.layer.cornerRadius = 12
        toolbarView.layer.shadowColor = UIColor.black.cgColor
        toolbarView.layer.shadowRadius = 12
        toolbarView.layer.shadowOpacity = 0.10
        toolbarView.layer.shadowOffset = CGSize(width: 0, height: 5)
        
        canvasView.layer.shadowColor = UIColor.black.cgColor
        canvasView.layer.shadowRadius = 12
        canvasView.layer.shadowOpacity = 0.10
        canvasView.layer.shadowOffset = CGSize(width: 0, height: 5)
        
        canvasView.layer.cornerRadius = 12
        canvasView.isUserInteractionEnabled = true
        
        toolbarView.loadTools()
        canvasView.setupViews()
        
        toolbarView.delegate = self
        
        colorPicker.frame = CGRect(x: Int(self.view.center.x - (CGFloat(colorPickerWidth / 2))), y: Int(self.toolbarView.center.y - (self.toolbarView.frame.height * 2) - 50), width: colorPickerWidth, height: colorPickerHeight)
        brightnessSlider.frame = CGRect(x: Int(self.view.center.x - (CGFloat(brightnessSliderWidth / 2))), y: Int(colorPicker.center.y) + 85, width: brightnessSliderWidth, height: brightnessSliderHeight)
        
        colorPicker.connect(brightnessSlider)
        colorPicker.addHandle(at: .white)
        
        colorPicker.addTarget(self, action: #selector(colorDidChangeValue(_:)), for: .valueChanged)
        brightnessSlider.addTarget(self, action: #selector(sliderDidChangeValue(_:)), for: .valueChanged)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        spinner.alpha = 0.0

        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        let hideKeyboardGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedOutOfKeyboard(_ :)))
        self.view.addGestureRecognizer(hideKeyboardGestureRecognizer)
    }
    
    @objc func tappedOutOfKeyboard(_ gesture: UITapGestureRecognizer) {
        canvasView.hideKeyboard()
    }
    
    @IBAction func clearCanvas(_ sender: Any) {
        canvasView.clearCanvas()
    }
    
    @IBAction func exportImage(_ sender: Any) {
        if let canvasExport = canvasView.saveAsImage() {
            UIImageWriteToSavedPhotosAlbum(canvasExport, nil, nil, nil)
        }
    }
    
    func randomString(length: Int) -> String {

        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)

        var randomString = ""

        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }

        return randomString
    }
    
    @objc func colorDidChangeValue(_ picker: ChromaColorPicker) {
        if let color = picker.currentHandle?.color {
            canvasView.changeBackgroundColor(to: color)
        }
    }
    
    @objc func sliderDidChangeValue(_ slider: ChromaBrightnessSlider) {
        canvasView.changeBackgroundColor(to: slider.currentColor)
    }
    
    func addRemoveColorPicker() {
        DispatchQueue.main.async {
            if self.colorPickerHidden {
                self.colorPicker.removeFromSuperview()
                self.brightnessSlider.removeFromSuperview()
            } else {
                self.view.addSubview(self.colorPicker)
                self.view.addSubview(self.brightnessSlider)
            }
        }
        
        colorPickerHidden = !colorPickerHidden
    }
}

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

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            self.picker.dismiss(animated: true, completion: nil)
            fatalError("failed to fetch image")
        }
        self.spinner.alpha = 1.0
        
        self.originalImage = image
        self.picker.dismiss(animated: true, completion: nil)
        
        APIController.sharedInstance.uploadImage(image) { (success, maskImage) in
            self.spinner.alpha = 0

            if success && maskImage != nil {
                if let toucanImage = Toucan(image: self.originalImage!).maskWithImage(maskImage: maskImage!).image {
                    self.maskedImage = toucanImage
                    self.canvasView.addImage(image: toucanImage)
                }
            }
        }
    }
}


class APIController {
    static var sharedInstance = APIController()
    
    var endpoint = "http://ec2-54-92-162-148.compute-1.amazonaws.com/upload_image"
    
    func uploadImage(_ image: UIImage, completion: @escaping (_ success: Bool, _ image: UIImage?) -> ()) {
        if let imageData = image.jpegData(compressionQuality: 0.4) {
            AF.upload(multipartFormData: { (multiFormData) in
                multiFormData.append(imageData, withName: "imagefile", fileName: "\(self.randomString(length: 8)).jpg", mimeType: "image/jpeg")
            }, to: URL(string: endpoint)!).responseData { (dataResponse) in
                if let data = dataResponse.data {
                    let image = UIImage(data: data)
                    completion(true, image)
                } else {
                    print("done false")
                    completion(false, nil)
                }
            }
        }
    }
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
}
