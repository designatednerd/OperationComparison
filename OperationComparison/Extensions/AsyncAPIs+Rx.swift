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

extension Reactive where Base: FakeAPI {
    
    static func fetchUser() -> Single<User> {
        return Single.create { single in
            FakeAPI.fetchUser { result in
                result.finishSingle(single)
            }
            
            return Disposables.create()
        }
    }
}

extension Reactive where Base: RealAPI {
    
    static func fetchImage(for user: User) -> Single<UIImage> {
        return Single.create { single in
            RealAPI.fetchImage(for: user) { result in
                result.finishSingle(single)
            }
            
            return Disposables.create()
        }
    }
}

extension Reactive where Base: ImageResizer {
    
    static func resizeImage(_ image: UIImage, to size: CGSize) -> Single<UIImage> {
        return Single.create { single in
            ImageResizer.resizeImage(image, to: size) { result in
                result.finishSingle(single)
            }
            
            return Disposables.create()
        }
    }
}
