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
    private var isShown: Bool = false
    public var card: Card? {
        didSet{
            
        }
    }
    
    //MARK: - IB Outlets
    @IBOutlet weak var backImageView :  UIImageView!
    @IBOutlet weak var frontImageView: UIImageView!
    

    
    //MARK: - Helper Methods
    fileprivate func setupImageViews(){
        frontImageView.layer.cornerRadius = 5.0
        backImageView.layer.cornerRadius = 5.0
        frontImageView.layer.masksToBounds = true
        backImageView.layer.masksToBounds = true
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
