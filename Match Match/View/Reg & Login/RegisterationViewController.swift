//
//  ViewController.swift
//  Match Match
//
//  Created by Ali on 26.11.2019.
//  Copyright © 2019 Ali. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import JGProgressHUD

class RegisterationViewController: UIViewController {
    
    //MARK: - Properties
    let gradientLayer = CAGradientLayer()
    @IBInspectable var firstColor: UIColor = #colorLiteral(red: 0.9438400269, green: 0.6414444447, blue: 0.3371585011, alpha: 1)
    @IBInspectable var secondColor: UIColor = #colorLiteral(red: 0.8949478269, green: 0.3861214817, blue: 0.2596493065, alpha: 1)
    let registerationViewModel = RegisterationViewModel()
    let disposeBag = DisposeBag()
    let registerHud = JGProgressHUD(style: .dark)
    
    //MARK: - IB Outlets
    @IBOutlet weak var emailField: TextFieldView!
    @IBOutlet weak var nicknameField: TextFieldView!
    @IBOutlet weak var passwordField: TextFieldView!
    @IBOutlet weak var passwordAgianField: TextFieldView!
    @IBOutlet weak var registerButton: UIButton!
    
    //MARK: - View Life Cycly
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
        gradientLayer.locations = [0.1, 1]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
        registerButton.layer.cornerRadius = 10
        setupTextFields()
        setupBindings()
        setupBindables()

    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        gradientLayer.frame = view.frame
    }
    //MARK: - File Private Methods
    fileprivate func setupTextFields() {
        nicknameField.validationType = .normalValidation
        emailField.validationType = .emailValidation
        passwordField.validationType = .passwordValidation
        passwordAgianField.validationType = .passwordValidation
        passwordField.textField.isSecureTextEntry = true
        passwordAgianField.textField.isSecureTextEntry = true
        
        nicknameField.textField.addTarget(self, action: #selector(handleTextChanged), for: .editingChanged)
        emailField.textField.addTarget(self, action: #selector(handleTextChanged), for: .editingChanged)
        passwordField.textField.addTarget(self, action: #selector(handleTextChanged), for: .editingChanged)
        passwordAgianField.textField.addTarget(self, action: #selector(handleTextChanged), for: .editingChanged)
    }
    fileprivate func   setupBindings() {
        //emailField.textField.
        registerButton.rx.tap.do(onNext: { [unowned self] in
            //1. resign first responders to dismiss keyboard
            self.emailField.textField.resignFirstResponder()
            self.passwordField.textField.resignFirstResponder()
            self.nicknameField.textField.resignFirstResponder()

           
        }).subscribe(onNext: {  [unowned self] in
        //2. perform register
            self.registerationViewModel.performRegistering { (error) in
                if let error = error {
                    // show hud with error
                    self.showHud(withError: error)
                  return
                }
            }
        }).disposed(by: disposeBag)
    }
    
    fileprivate  func setupBindables() {
         //check form validity
        registerationViewModel.observableIsFormValid.subscribe(onNext: {[unowned self] isFormValid in
            if isFormValid == true {
                self.registerButton.isEnabled = true
                self.registerButton.setTitleColor(.black, for: .normal)
                       }
                else {
                self.registerButton.isEnabled = false
                self.registerButton.setTitleColor(.lightGray, for: .normal)
                }
            }).disposed(by: disposeBag)
               
        // on registering success
        registerationViewModel.observableIsRegistering.subscribe(onNext: { [unowned self] (isRegistering) in
        guard let isRegistering = isRegistering else {return}
        if isRegistering {
            // show registering hud
            self.registerHud.textLabel.text = "Registering.."
            self.registerHud.show(in: self.view)
            self.registerHud.textLabel.text = "Done!"
           
        } else {
            // dismiss it
            self.registerHud.dismiss(afterDelay: 1.5)
            self.navigationController?.pushViewController(HomeViewController.fromStroyBoard(identifier: "homeController"), animated: true)
            }
        }).disposed(by: disposeBag)
      // check password matching
        registerationViewModel.observableIsPasswordMatch.subscribe(onNext: { [unowned self](isMatch) in
            guard let isMatch = isMatch else {return}
            if !isMatch {
                self.passwordAgianField.messageLbl.text = "Passowrd doesnt match"
                //self.passwordAgianField.decorateInvalidUI()
            } else {
                self.passwordAgianField.messageLbl.text = ""
            }
            }).disposed(by: disposeBag)
    }
    
    
    fileprivate func showHud(withError error: Error) {
        registerHud.dismiss()
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Failed to Register"
        hud.detailTextLabel.text = error.localizedDescription
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 4)
    }
    
    //MARK: - Objc Methods
    @objc fileprivate func handleTextChanged(tf: UITextField) {
        if tf == emailField.textField {
            registerationViewModel.email = tf.text
        }
        else if tf == passwordField.textField {
            registerationViewModel.password = tf.text
        }
        else if tf == nicknameField.textField {
            registerationViewModel.nickName = tf.text
        }
        else if tf == passwordAgianField.textField {
            registerationViewModel.passwordAgain = tf.text
        }

    }
    
    //MARK: - IB Actions

    @IBAction func handleRegister(_ sender: UIButton) {
        print("Handle")

    }
}

