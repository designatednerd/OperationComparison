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
                           completion: @escaping (Result<UIImage, Swift.Error>) -> Void) {
        getData(from: URL(string: user.imageURL)!) { dataResult in
            switch dataResult {
            case .success(let data):
                guard let image = UIImage(data: data) else {
                    completion(.failure(Error.dataNotImage))
                    return
                }
                
                completion(.success(image))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    private static func getData(from url: URL, fakingDelay delay: TimeInterval = 1, completion: @escaping (Result<Data, Swift.Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            var result: Result<Data, Swift.Error>
            defer {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    completion(result)
                }
            }
            
            if let error = error {
                result = .failure(error)
                return
            }
            
            if let data = data {
                result = .success(data)
                return
            }
            
            result = .failure(Error.noDataDownloaded)
        }.resume()
    }
}
