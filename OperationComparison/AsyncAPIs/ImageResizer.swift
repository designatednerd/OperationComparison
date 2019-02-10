//
//  ImageResizer.swift
//  OperationComparison
//
//  Created by Ellen Shapiro on 10/10/18.
//  Copyright © 2018 Bakken & Baeck. All rights reserved.
//

import UIKit

class ImageResizer: NSObject {
    
    enum Error: Swift.Error {
        case imageDidNotResize
    }
    
    static func resizeImage(_ image: UIImage,
                            to size: CGSize,
                            fakingDelay delay: TimeInterval = 1,
                            completion: @escaping (Swift.Result<UIImage, Swift.Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
            image.draw(in: CGRect(origin: .zero, size: size))
            
            var result: Result<UIImage, Swift.Error>
            defer {
                UIGraphicsEndImageContext()
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    completion(result)
                }
            }
            
            guard let resized = UIGraphicsGetImageFromCurrentImageContext() else {
                result = .failure(Error.imageDidNotResize)
                return
            }
            
            result = .success(resized)
        }
    }
}
