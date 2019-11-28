//
//  ViewController.swift
//  Match Match
//
//  Created by Ali on 26.11.2019.
//  Copyright © 2019 Ali. All rights reserved.
//

import UIKit

class RegisterationViewController: UIViewController {
    
    //MARK: - Properties
      let gradientLayer = CAGradientLayer()
      @IBInspectable var firstColor: UIColor = #colorLiteral(red: 0.9438400269, green: 0.6414444447, blue: 0.3371585011, alpha: 1)
      @IBInspectable var secondColor: UIColor = #colorLiteral(red: 0.8949478269, green: 0.3861214817, blue: 0.2596493065, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
        gradientLayer.locations = [0.1, 1]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        gradientLayer.frame = view.frame
    }

}

