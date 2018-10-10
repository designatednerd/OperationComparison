//
//  Result.swift
//  OperationComparison
//
//  Created by Ellen Shapiro on 10/10/18.
//  Copyright © 2018 Bakken & Baeck. All rights reserved.
//

import Foundation
import PromiseKit

enum Result<T> {
    case success(_ item: T)
    case error(_ error: Error)
}

// MARK: - PromiseKit helpers

extension Result {
    
    func sealPromise(with seal: Resolver<T>) {
        switch self {
        case .success(let item):
            seal.fulfill(item)
        case .error(let error):
            seal.reject(error)
        }
    }
    
    static func promiseFromFunction(_ function: @escaping (@escaping ResultCompletion<T>) -> Void) -> Promise<T> {
        return Promise { seal in
            function { result in
                result.sealPromise(with: seal)
            }
        }
    }
    
    static func promiseFromFunction<U>(with parameter: U,
                                       _ function: @escaping (U, @escaping ResultCompletion<T>) -> Void) -> Promise<T> {
        return Promise { seal in
            function(parameter) { result in
                result.sealPromise(with: seal)
            }
        }
    }
}

