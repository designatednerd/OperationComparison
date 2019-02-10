//
//  AsyncAPIs+Promise.swift
//  OperationComparison
//
//  Created by Ellen Shapiro on 10/10/18.
//  Copyright © 2018 Bakken & Baeck. All rights reserved.
//

import Foundation
import PromiseKit

// Have to specify this is Swift's result or it thinks it's PromiseKit's result.
extension Swift.Result {

    func sealPromise(with seal: Resolver<Success>) {
        switch self {
        case .success(let item):
            seal.fulfill(item)
        case .failure(let error):
            seal.reject(error)
        }
    }
}

extension FakeAPI {
    
    static func fetchUser() -> Promise<User> {
        return Promise { seal in
            fetchUser { result in
                result.sealPromise(with: seal)
            }
        }
    }
}

extension RealAPI {
    
    static func fetchImage(for user: User) -> Promise<UIImage> {
        return Promise { seal in
            fetchImage(for: user) { result in
                result.sealPromise(with: seal)
            }
        }
    }
}

extension ImageResizer {
    
    static func resizeImage(_ image: UIImage, to size: CGSize) -> Promise<UIImage> {
        return Promise { seal in
            resizeImage(image, to: size) { result in
                result.sealPromise(with: seal)
            }
        }
    }
}

