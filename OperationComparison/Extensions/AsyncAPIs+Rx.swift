//
//  ImageResizer+Promise.swift
//  OperationComparison
//
//  Created by Ellen Shapiro on 10/10/18.
//  Copyright © 2018 Bakken & Baeck. All rights reserved.
//

import Foundation
import RxSwift

extension Result {
    
    func finishSingle(_ single: (SingleEvent<T>) -> Void) {
        switch self {
        case .success(let item):
            single(.success(item))
        case .error(let error):
            single(.error(error))
        }
    }
}

extension FakeAPI {
    
    static func rxFetchUser() -> Single<User> {
        return Single.create { single in
            fetchUser { result in
                result.finishSingle(single)
            }
            
            return Disposables.create()
        }
    }
}

extension RealAPI {
    
    static func rxFetchImage(for user: User) -> Single<UIImage> {
        return Single.create { single in
            fetchImage(for: user) { result in
                result.finishSingle(single)
            }
            
            return Disposables.create()
        }
    }
}

extension ImageResizer {
    
    static func rxResizeImage(_ image: UIImage, to size: CGSize) -> Single<UIImage> {
        return Single.create { single in
            resizeImage(image, to: size) { result in
                result.finishSingle(single)
            }
            
            return Disposables.create()
        }
    }
}
