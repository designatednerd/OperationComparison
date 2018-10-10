//
//  Promise+SideEffect.swift
//  OperationComparison
//
//  Created by Ellen Shapiro on 10/10/18.
//  Copyright © 2018 Bakken & Baeck. All rights reserved.
//

import Foundation
import PromiseKit

extension Thenable {
    
    func performSideEffect(transform: @escaping () throws -> Void) -> Promise<T> {
        return map { incoming in
            try transform()
            return incoming
        }
    }
}
