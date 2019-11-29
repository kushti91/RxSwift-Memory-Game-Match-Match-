//
//  RegisterationViewModel.swift
//  Match Match
//
//  Created by Ali on 28.11.2019.
//  Copyright © 2019 Ali. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Firebase


class RegisterationViewModel {
    //MARK: - Properties
    public var nickName: String? {didSet {checkFormValidity()}}
    public var email: String?    {didSet {checkFormValidity()}}
    public var password: String? {didSet {checkFormValidity()}}
    
    //MARK: - FilePrivates
    fileprivate func checkFormValidity() {
           let isFormValid =  nickName?.isEmpty == false && email?.isEmpty == false && password?.isEmpty == false
        observableIsFormValid.accept(isFormValid)
       }
    public func performRegistering(completion: @escaping(Error?) -> () ) {
         self.observableIsRegistering.accept(true)
         guard let email = email, let password = password else {return}
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
               if let error = error {
                 print(error)
                   completion(error)
                 return
               }
             completion(nil)
        }
        self.observableIsRegistering.accept(false)
     
     }
    
    //MARK: - Rx VARs
    public var observableIsFormValid = BehaviorRelay<Bool>(value: false)
    public var observableIsRegistering = BehaviorRelay<Bool?>(value: nil)


}
