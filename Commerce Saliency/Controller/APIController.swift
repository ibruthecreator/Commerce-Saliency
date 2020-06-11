//
//  APIController.swift
//  Commerce Saliency
//
//  Created by Mohammed Ibrahim on 2020-06-10.
//  Copyright © 2020 Mohammed Ibrahim. All rights reserved.
//

import UIKit
import Alamofire

class APIController {
    /// Singleton
    static var sharedInstance = APIController()
    
    /// API endpoint
    var endpoint = "http://ec2-54-92-162-148.compute-1.amazonaws.com/upload_image"
    
    /// Upload an image to the API endpoint
    /// - Parameters:
    ///   - image: image to be uploaded
    ///   - completion: completion handler when the method is completed
    /// - Returns: success boolean and result image (mask)
    func uploadImage(_ image: UIImage, completion: @escaping (_ success: Bool, _ image: UIImage?) -> ()) {
        if let imageData = image.jpegData(compressionQuality: 0.4) {
            AF.upload(multipartFormData: { (multiFormData) in
                multiFormData.append(imageData, withName: "imagefile", fileName: "\(self.randomString()).jpg", mimeType: "image/jpeg")
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
    
    /// Generate a random string
    /// - Parameter length: length of string, default of 8
    /// - Returns: random string
    func randomString(length: Int = 8) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
}
