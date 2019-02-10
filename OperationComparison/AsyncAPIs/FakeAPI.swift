//
//  FakeAPI.swift
//  OperationComparison
//
//  Created by Ellen Shapiro on 10/10/18.
//  Copyright © 2018 Bakken & Baeck. All rights reserved.
//

import UIKit

class FakeAPI: NSObject {
    
    static func fetchUser(completion: @escaping (Swift.Result<User, Swift.Error>) -> Void) {
        pretendWereGoingToTheInternet(for: 1.5) {
            completion(.success(User.fakeUser))
        }
    }

    private static func pretendWereGoingToTheInternet(for seconds: TimeInterval, completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: completion)
    }

}
