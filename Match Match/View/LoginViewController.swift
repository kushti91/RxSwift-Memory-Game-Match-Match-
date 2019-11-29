//
//  LoginViewController.swift
//  Match Match
//
//  Created by Ali on 28.11.2019.
//  Copyright © 2019 Ali. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Firebase
@IBDesignable
class LoginViewController: UIViewController {
    
    //MARK: - Properties
    let gradientLayer = CAGradientLayer()
    @IBInspectable var firstColor: UIColor = #colorLiteral(red: 0.9438400269, green: 0.6414444447, blue: 0.3371585011, alpha: 1)
    @IBInspectable var secondColor: UIColor = #colorLiteral(red: 0.8949478269, green: 0.3861214817, blue: 0.2596493065, alpha: 1)
    let loginVieweModel = LoginViewModel()
    let disposeBag = DisposeBag()
    @IBOutlet weak var emailInputView: TextFieldView!
    @IBOutlet weak var passwordInputView: TextFieldView!
    @IBOutlet weak var loginButton: UIButton!
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true//setNavigationBarHidden(true, animated: false)
        gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
        gradientLayer.locations = [0.1, 1]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        emailInputView.validationType = .emailValidation
        passwordInputView.validationType = .passwordValidation
        loginButton.layer.cornerRadius  =  10
//        loginButton.layer.borderColor = UIColor.black.cgColor
//        loginButton.layer.borderWidth = 3
        
    
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
             view.prepareForInterfaceBuilder()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        gradientLayer.frame = view.frame
    }
    @IBAction func handleLogin(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        
        }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print( Auth.auth().currentUser )
        if Auth.auth().currentUser != nil {
            print("logged in")
            navigationController?.popViewController(animated: true)
    }
    }

    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }


}


extension LoginViewController {
    //MARK: -Setup Rx
    
    func setupLoginObserver() {
loginVieweModel.isPerformingLogin.asObservable()
  .subscribe(onNext: {
    [unowned self] isPerformingLogin in
    
            })
  .disposed(by: disposeBag)
        
loginVieweModel.isPerformingLogin.asObservable().subscribe(onNext: { (isPerformingLogin) in
            //success code goes here
        },
    onError: { (error) in
            //error code goes here
    },
    onCompleted: {
               //complete code goes here
    }, onDisposed: {
        //dispose code goes here
    }).disposed(by: disposeBag)
    }
}

