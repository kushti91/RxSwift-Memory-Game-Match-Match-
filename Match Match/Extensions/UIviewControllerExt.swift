//
//  UIviewControllerExt.swift
//  Match Match
//
//  Created by Ali on 29.11.2019.
//  Copyright © 2019 Ali. All rights reserved.
//

import UIKit


extension UIViewController {
    class func fromStroyBoard(identifier: String) -> UIViewController{
      let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier) as UIViewController
          return viewController
}
}
