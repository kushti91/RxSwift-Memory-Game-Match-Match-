//
//  Card.swift
//  Match Match
//
//  Created by Ali on 30.11.2019.
//  Copyright © 2019 Ali. All rights reserved.
//

import UIKit

class Card {
   
    
    var id: String
    var isShown: Bool = false
    var image: UIImage!
    
    static var allCards = [Card]()

    
    init(image: UIImage) {
        self.id = UUID().uuidString
        self.isShown = false
        self.image = image
        Card.allCards.append(self)
    }
    
    init(card: Card) {
           self.id = card.id
           self.isShown = card.isShown
           self.image = card.image
    }
  
    
    func equals(_ card: Card) -> Bool {
        return (card.id == id)
    }
       
    func copy() -> Card {
           return Card(card: self)
    }
}
