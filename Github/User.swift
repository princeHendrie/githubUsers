//
//  User.swift
//  Github
//
//  Created by Hendri Hermansyah on 22/05/19.
//  Copyright © 2019 Prince. All rights reserved.
//

import Foundation

class User {
    var id: Int
    var name: String
    var image: String
    
    init(id: Int,
         name: String,
         image : String) {
        
        self.id = id
        self.name = name
        self.image = image
        
    }
}
