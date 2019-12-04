//
//  User.swift
//  Match Match
//
//  Created by Ali on 28.11.2019.
//  Copyright © 2019 Ali. All rights reserved.
//

import Foundation

struct User {
    let id: String?
    let nickName: String?
    let highScore: Int?
    let level: Int?
    
    init(dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String ?? ""
        self.nickName = dictionary["nickName"] as? String ?? ""
        self.highScore = dictionary["highScore"] as? Int ?? 0
        self.level = dictionary["level"] as? Int ?? 0
        
    }
}
