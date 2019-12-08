//
//  LoginViewController.swift
//  Match Match
//
//  Created by Ali on 28.11.2019.
//  Copyright © 2019 Ali. All rights reserved.
//

import UIKit
import Firebase
import RxCocoa
import RxSwift
import JGProgressHUD

@IBDesignable
class LoginViewController: UIViewController {
    
    //MARK: - Properties
    fileprivate let gradientLayer = CAGradientLayer()
    @IBInspectable var firstColor: UIColor = #colorLiteral(red: 0.9438400269, green: 0.6414444447, blue: 0.3371585011, alpha: 1)
    @IBInspectable var secondColor: UIColor = #colorLiteral(red: 0.8949478269, green: 0.3861214817, blue: 0.2596493065, alpha: 1)
    fileprivate let disposeBag = DisposeBag()
    fileprivate let loginVieweModel = LoginViewModel()

    
    //MARK: - IB Outlets
    @IBOutlet weak var emailInputView: TextFieldView!
    @IBOutlet weak var passwordInputView: TextFieldView!
    @IBOutlet weak var loginButton: UIButton!
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupTextFields()
        setupBindings()
        setupButtonTap()
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
             view.prepareForInterfaceBuilder()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        gradientLayer.frame = view.frame
    }
    
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
         navigationController?.navigationBar.isHidden = true
         
    }
    //MARK: - FilePrivate Methods
    fileprivate func setupLayout() {
        navigationController?.navigationBar.isHidden = true//setNavigationBarHidden(true, animated: false)
        gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
        gradientLayer.locations = [0.1, 1]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
       
        loginButton.layer.cornerRadius  =  10
    }
    fileprivate func setupTextFields() {
        emailInputView.validationType = .emailValidation
        passwordInputView.validationType = .passwordValidation
        passwordInputView.textField.isSecureTextEntry = true
        passwordInputView.textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        emailInputView.textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
    }
    fileprivate func showHud(withError error : String) {
        let hud = JGProgressHUD(style: .dark)

        hud.textLabel.text = "Error!"
        hud.detailTextLabel.text = error
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 3)
    }
    fileprivate func showHud(withMessage message : String, showing: Bool) {
        let hud = JGProgressHUD(style: .dark)
         
        if showing {
            hud.show(in: self.view)
            hud.textLabel.text = "Loging in!"
            hud.detailTextLabel.text = message
        }
        else {
        hud.dismiss(afterDelay: 1)
        }
    }
    
    //MARK: - Objc Methods
    @objc fileprivate func textChanged(tf: UITextField) {
        if tf == passwordInputView.textField {
            loginVieweModel.password = tf.text
        }
        else if tf == emailInputView.textField {
            loginVieweModel.email = tf.text
        }
    }
    
    //MARK: - Rx
    fileprivate func setupButtonTap() {
        loginButton.rx.tap.bind {
            print("Will login")
            self.loginVieweModel.performLogin()
            
        }.disposed(by: disposeBag)
    }
    
    fileprivate func setupBindings()  {
        
        //check if it is performing login
        loginVieweModel
            .isPerformingLogin
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (isperforingLogin) in
                self.showHud(withMessage: "Please wait..", showing: isperforingLogin)
            }).disposed(by: disposeBag)
        
        // in case of success
        loginVieweModel
            .isSuccess
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (isSuccess) in
                if isSuccess {
        self.navigationController?.pushViewController(HomeViewController.fromStroyBoard(identifier: "homeController"), animated: true)
                }
            }).disposed(by: disposeBag)
        
        //in case of error
        loginVieweModel
            .errorMessage
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (error) in
                guard let error = error else {return}
                self.showHud(withError: error )
            }).disposed(by: disposeBag)
    }
}






