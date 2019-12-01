//
//  ArrayExt.swift
//  Match Match
//
//  Created by Ali on 30.11.2019.
//  Copyright © 2019 Ali. All rights reserved.
//

import UIKit

extension Array {
        mutating func shuffle() {
            for _ in 0...self.count {
                sort { (_,_) in arc4random() < arc4random() }
            }
        }
    }

