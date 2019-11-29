//
//  LoginViewModel.swift
//  Match Match
//
//  Created by Ali on 28.11.2019.
//  Copyright © 2019 Ali. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Firebase

class LoginViewModel {
    public var email: String? {
        didSet {
         checkFormValidity()
        }
    }
    
    public var password: String? {
         didSet {
        checkFormValidity()
         }
     }
    private let disposeBag = DisposeBag()
    
    // Reactive programming
    public var isSuccess = BehaviorRelay<Bool>(value: false)
    public var isPerformingLogin = BehaviorRelay<Bool>(value: false)
    public var errorMessage = BehaviorRelay<String?>(value: nil)
    
    fileprivate func checkFormValidity() {
        let isFormValid = email?.isEmpty == false && password?.isEmpty == false
        // set bindalbel value here
        
    }
    fileprivate func performLogin() {
        guard let email = email, let password = password else {
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
        }
    }

    
}
