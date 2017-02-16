//
//  AddPinLocationViewController.swift
//  On The Map
//
//  Created by Flavio Kreis on 14/02/17.
//  Copyright © 2017 Flavio Kreis. All rights reserved.
//

import UIKit

class AddPinLocationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var locationTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        locationTextField.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "myLocationSegue" {
            let navigationController = segue.destination as! UINavigationController
            let destination = navigationController.topViewController as? AddPinUrlViewController
            destination?.location = locationTextField.text!
        }
    }

}
