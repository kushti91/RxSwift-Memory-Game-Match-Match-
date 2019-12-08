//
//  CardViewCell.swift
//  Match Match
//
//  Created by Ali on 29.11.2019.
//  Copyright © 2019 Ali. All rights reserved.
//

import UIKit

class CardViewCell: UICollectionViewCell {
    
    //MARK: - Properties
    static let identifier = "cellId"
    public var isShown: Bool = false
    public var cards =  [Card]()
    
    //MARK: - IB Outlets
    @IBOutlet weak var backImageView :  UIImageView!
    @IBOutlet weak var frontImageView: UIImageView!
    
    public var card: Card? {
          didSet{
              
              guard let card = card else { return }
              cards.append(card)
              frontImageView.image = card.image
              setupImageViews()
          
      }
    }
 
    //MARK: - Helper Methods
    fileprivate func setupImageViews(){
        frontImageView.layer.cornerRadius = 10.0
        backImageView.layer.cornerRadius = 10.0
        frontImageView.layer.masksToBounds = true
        backImageView.layer.masksToBounds = true
        frontImageView.frame = self.contentView.frame
        backImageView.frame = self.contentView.frame
    }
    
    public func configureCell() {
    self.contentView.layer.cornerRadius = 10
    self.contentView.layer.borderWidth = 1.0

    self.contentView.layer.borderColor = UIColor.clear.cgColor
    self.contentView.layer.masksToBounds = true

    self.layer.shadowColor = UIColor.gray.cgColor
    self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
    self.layer.shadowRadius = 2.0
    self.layer.shadowOpacity = 1.0
    self.layer.masksToBounds = false
    self.layer.shadowPath = UIBezierPath(roundedRect:self.bounds, cornerRadius:self.contentView.layer.cornerRadius).cgPath
    }
    public func flipCard(_ show: Bool, animted: Bool) {
        frontImageView.isHidden = false
        backImageView.isHidden = false
        isShown = show
        
        if animted {
            if show {
                UIView.transition(
                    from: backImageView,
                    to: frontImageView,
                    duration: 0.5,
                    options: [.transitionFlipFromRight, .showHideTransitionViews],
                    completion: { (finished: Bool) -> () in
                })
            } else {
                UIView.transition(
                    from: frontImageView,
                    to: backImageView,
                    duration: 0.5,
                    options: [.transitionFlipFromRight, .showHideTransitionViews],
                    completion:  { (finished: Bool) -> () in
                })
            }
        } else {
            if show {
                bringSubviewToFront(frontImageView)
                backImageView.isHidden = true
            } else {
                bringSubviewToFront(backImageView)
                frontImageView.isHidden = true
            }
        }
    }
}
