//
//  Result.swift
//  OperationComparison
//
//  Created by Ellen Shapiro on 10/10/18.
//  Copyright © 2018 Bakken & Baeck. All rights reserved.
//

enum Result<T> {
    case success(_ item: T)
    case error(_ error: Error)
}
