//
//  User.swift
//  OperationComparison
//
//  Created by Ellen Shapiro on 10/10/18.
//  Copyright © 2018 Bakken & Baeck. All rights reserved.
//

import Foundation

struct User {
    let name: String
    let imageURL: String
    
    static var fakeUser: User {
        return User(name: "Fakey McFakerson",
                    imageURL: "https://bakkenbaeck.com/images/offices/covers/amsterdam@2x.2305df1e81.jpg")
    }
}
