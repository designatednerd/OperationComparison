//
//  RealAPI.swift
//  OperationComparison
//
//  Created by Ellen Shapiro on 10/10/18.
//  Copyright © 2018 Bakken & Baeck. All rights reserved.
//

import UIKit

class RealAPI: NSObject {
    
    enum Error: Swift.Error {
        case noDataDownloaded
        case dataNotImage
    }
    
    static func fetchImage(for user: User,
                           completion: @escaping (Result<UIImage>) -> Void) {    
        getData(from: URL(string: user.imageURL)!) { dataResult in
            switch dataResult {
            case .success(let data):
                guard let image = UIImage(data: data) else {
                    completion(.error(Error.dataNotImage))
                    return
                }
                
                completion(.success(image))
            case .error(let error):
                completion(.error(error))
            }
        }
    }
    
    
    private static func getData(from url: URL, fakingDelay delay: TimeInterval = 1, completion: @escaping (Result<Data>) -> Void) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            var result: Result<Data>
            defer {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    completion(result)
                }
            }
            
            if let error = error {
                result = .error(error)
                return
            }
            
            if let data = data {
                result = .success(data)
                return
            }
            
            result = .error(Error.noDataDownloaded)
            }.resume()
    }
}
