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
    
    // Reactive programming
    public var isSuccess = BehaviorRelay<Bool>(value: false)
    public var isFormValid = BehaviorRelay<Bool>(value: false)
    public var isPerformingLogin = BehaviorRelay<Bool>(value: false)
    public var errorMessage = BehaviorRelay<String?>(value: nil)
    
    fileprivate func checkFormValidity() {
        let isValid = email?.isEmpty == false && password?.isEmpty == false
        isFormValid.accept(isValid)
    }
    public func performLogin() {
        guard let email = email, let password = password else {
            return
        }
        isPerformingLogin.accept(true)
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                self.errorMessage.accept(error.localizedDescription)
                return
            }
            self.isSuccess.accept(true)
            self.isPerformingLogin.accept(false)
        }
    }

    
}
