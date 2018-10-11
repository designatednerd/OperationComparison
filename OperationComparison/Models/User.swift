//
//  User.swift
//  OperationComparison
//
//  Created by Ellen Shapiro on 10/10/18.
//  Copyright © 2018 Bakken & Baeck. All rights reserved.
//

struct User {
    let name: String
    let imageURL: String
    
    static var fakeUser: User {
        let randomImages = [
            "https://bakkenbaeck.com/images/offices/covers/amsterdam@2x.2305df1e81.jpg",
            "https://bakkenbaeck.com/images/offices/covers/bonn@2x.4ef90789e3.jpg",
            "https://bakkenbaeck.com/images/offices/covers/oslo@2x.277cee31f9.jpg",
            "https://bakkenbaeck.com/images/offices/covers/sanfrancisco@2x.1b6aee123d.jpg",
        ]
        
        return User(name: "Fakey McFakerson",
                    imageURL: randomImages.randomElement()!)
    }
}
