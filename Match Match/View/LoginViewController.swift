//
//  LoginViewController.swift
//  Match Match
//
//  Created by Ali on 28.11.2019.
//  Copyright © 2019 Ali. All rights reserved.
//

import UIKit

@IBDesignable
class LoginViewController: UIViewController {
    
    //MARK: - Properties
    let gradientLayer = CAGradientLayer()
    @IBInspectable var firstColor: UIColor = #colorLiteral(red: 0.9438400269, green: 0.6414444447, blue: 0.3371585011, alpha: 1)
    @IBInspectable var secondColor: UIColor = #colorLiteral(red: 0.8949478269, green: 0.3861214817, blue: 0.2596493065, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
        gradientLayer.locations = [0.1, 1]
        self.view.layer.addSublayer(gradientLayer)
    
    }
    override func prepareForInterfaceBuilder() {
        
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        gradientLayer.frame = view.frame
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
