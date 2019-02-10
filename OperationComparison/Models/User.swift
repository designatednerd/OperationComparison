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
        // Let's grab some random crap from my instagram!
        let randomImages = [
            "https://scontent-ams3-1.cdninstagram.com/vp/66b86ccbfddbe6fc6f980b0ea440d61b/5CE4C6D5/t51.2885-15/e35/43578459_246261869378716_6922717545703145472_n.jpg?_nc_ht=scontent-ams3-1.cdninstagram.com",
            "https://scontent-ams3-1.cdninstagram.com/vp/91969563d8deecdf797a45319aecc028/5CE3993D/t51.2885-15/e35/41163396_284088662207726_3012594673932828672_n.jpg?_nc_ht=scontent-ams3-1.cdninstagram.com",
            "https://scontent-ams3-1.cdninstagram.com/vp/8fe6b39c6d189e31702c2a162ec37128/5CEA7E7C/t51.2885-15/e35/35998742_1946966825593833_3371460546091024384_n.jpg?_nc_ht=scontent-ams3-1.cdninstagram.com",
            "https://scontent-ams3-1.cdninstagram.com/vp/9a3e1a9ebf8f9ce192431dad26766c8a/5CFB5395/t51.2885-15/e35/29715184_2039690519622232_2028413419249467392_n.jpg?_nc_ht=scontent-ams3-1.cdninstagram.com",
        ]
        
        return User(name: "Fakey McFakerson",
                    imageURL: randomImages.randomElement()!)
    }
}
