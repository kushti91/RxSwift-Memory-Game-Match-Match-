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
    public var email:    String? {didSet {checkFormValidity()}}
    public var password: String? {didSet {checkFormValidity()}}
    public var passwordAgain: String? { didSet{ checkFormValidity() }}
    
    //MARK: - FilePrivates
    fileprivate func checkFormValidity() {
           let isFormValid =  nickName?.isEmpty == false && email?.isEmpty == false && password?.isEmpty == false && checkPassWordMatch()
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
           
             let uid = Auth.auth().currentUser?.uid ?? ""
            guard let nickName = self.nickName else {return}
            let docData = ["nickName": nickName , "id": uid, "highScore": 0 , "level": 1] as [String : Any]
             Firestore.firestore().collection("users").document(uid).setData(docData as [String : Any]) { (error) in
                 if let error = error {
                     completion(error)
                     print("error")
                     return
                 }
                 completion(nil)
             self.observableIsRegistering.accept(false)
        }
     }
    }
    
    fileprivate func saveInfoToFireStore( completion: @escaping(Error?) -> ())
    {
        let uid = Auth.auth().currentUser?.uid ?? ""
        guard let nickName = nickName else {return}
        let docData = ["nickName": nickName , "id": uid, "highScore": "1"] as [String : Any]
        Firestore.firestore().collection("users").document(uid).setData(docData as [String : Any]) { (error) in
            if let error = error {
                completion(error)
                print("error")
                return
            }
            print("Registered")
            completion(nil)
        }
    }
    fileprivate func checkPassWordMatch() -> Bool {
        guard let passwordAgain = passwordAgain, let password = password else {return false}
        var isMatch = false
        if passwordAgain.count >= password.count {
            if passwordAgain == password {
                observableIsPasswordMatch.accept(true)
                isMatch =  true
            }else {
                observableIsPasswordMatch.accept(false)
                isMatch = false
            }
        }
        return isMatch
    }
    
    //MARK: - Rx VARs
    public var observableIsFormValid = BehaviorRelay<Bool>(value: false)
    public var observableIsPasswordMatch = BehaviorRelay<Bool?>(value: nil)
    public var observableIsRegistering = BehaviorRelay<Bool?>(value: nil)
    


}
