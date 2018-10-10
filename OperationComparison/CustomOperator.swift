//
//  CustomOperator.swift
//  OperationComparison
//
//  Created by Ellen Shapiro on 10/10/18.
//  Copyright © 2018 Bakken & Baeck. All rights reserved.
//

// This is based on Vincent Pradeilles' NSSpain 2018 lightning talk. Vincent's original approach is outlined here:
//https://github.com/vincent-pradeilles/slides/blob/master/nsspain-2018-solving-callback-hell-with-good-old-function-composition.pdf

infix operator -->: MultiplicationPrecedence

typealias ResultCompletion<T> = (Result<T>) -> Void

func --><T,U>(_ firstFunction: @escaping (@escaping ResultCompletion<T>) -> Void,
              _ secondFunction: @escaping (T, @escaping ResultCompletion<U>) -> Void) -> (@escaping ResultCompletion<U>) -> Void {
    return { completion in
        firstFunction { result in
            switch result {
            case .success(let item):
                secondFunction(item) { result2 in
                    completion(result2)
                }
            case .error(let error):
                completion(.error(error))
            }
        }
    }
}
