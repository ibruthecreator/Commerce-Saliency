//
//  ViewController.swift
//  Commerce Saliency
//
//  Created by Mohammed Ibrahim on 2020-05-18.
//  Copyright © 2020 Mohammed Ibrahim. All rights reserved.
//

import UIKit
import Alamofire
import Toucan

class ViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var uploadImageButton: UIButton!
    
    // MARK: - Variables
    var originalImage: UIImage?
    var maskedImage: UIImage?
    var picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        // Do any additional setup after loading the view.
    }

    // MARK: - Setup Views
    func setupViews() {
        previewImage.contentMode = .scaleAspectFit
        picker.delegate = self
        uploadImageButton.layer.cornerRadius = 8
    }
    
    /// Open gallery and allow user to select a single image, on selection it will make an API request to the EC2 instance
    @IBAction func uploadImagePressed(_ sender: Any) {
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
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
        
        self.originalImage = image
        self.picker.dismiss(animated: true, completion: nil)
        
        APIController.sharedInstance.uploadImage(image) { (success, maskImage) in
            if success && maskImage != nil {
                self.previewImage.image = Toucan(image: self.originalImage!).maskWithImage(maskImage: maskImage!).image
//                let mask = UIImageView(image: maskImage)
//                self.previewImage.mask = mask
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
                print("done")
                if let data = dataResponse.data {
                    let image = UIImage(data: data)
                    completion(true, image)
                } else {
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
