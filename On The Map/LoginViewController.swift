//
//  ViewController.swift
//  On The Map
//
//  Created by Flavio Kreis on 13/02/17.
//  Copyright © 2017 Flavio Kreis. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUIEnabled(true)
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            showAlertMessage("Username or Password Empty.")
        } else {
            setUIEnabled(false)
            
            OTMClient.sharedInstance().login(email: emailTextField.text!, password: passwordTextField.text!, completionHandlerForAuth: { (success, errorString) in
                DispatchQueue.main.async {
                    if success {
                        self.completeLogin()
                    } else {
                        self.showAlertMessage(errorString!)
                    }
                }
            })
        }
    }
    
    @IBAction func signUpPressed(_ sender: Any) {
        if let url = OTMClient.Udacity.SignUpUrl {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: Login
    
    private func completeLogin() {
        let controller = storyboard!.instantiateViewController(withIdentifier: "TabBarNavigationController") as! UITabBarController
        present(controller, animated: true, completion: nil)
    }
    
    func setUIEnabled(_ enabled: Bool) {
        emailTextField.isEnabled = enabled
        passwordTextField.isEnabled = enabled
        loginButton.isEnabled = enabled
        signUpButton.isEnabled = enabled
        
        if enabled {
            loginButton.alpha = 1.0
            signUpButton.alpha = 1.0
        } else {
            loginButton.alpha = 0.5
            signUpButton.alpha = 0.5
        }
    }
    
    func showAlertMessage(_ message: String){
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Ok", style: .default) { (alertAction) in
            self.setUIEnabled(true)
        }
        
        alertController.addAction(alertAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}

