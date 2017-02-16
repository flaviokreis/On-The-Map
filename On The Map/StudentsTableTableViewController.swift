//
//  StudentsTableTableViewController.swift
//  On The Map
//
//  Created by Flavio Kreis on 14/02/17.
//  Copyright © 2017 Flavio Kreis. All rights reserved.
//

import UIKit

class StudentsTableTableViewController: UITableViewController {

    var students: [StudentLocation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        OTMClient.sharedInstance().getUsersLocation(isReload: false) { (students, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.showAlertMessage(error)
                } else if students.count > 0 {
                    self.students = students
                    self.tableView.reloadData()
                }
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.students.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell", for: indexPath)

        let studentLocation = students[indexPath.row]
        
        cell.textLabel?.text = studentLocation.student.fullName
        cell.imageView?.image = #imageLiteral(resourceName: "pin")
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let studentLocation = students[indexPath.row]
        if UIApplication.shared.canOpenURL(URL(string: studentLocation.student.mediaURL)!){
            UIApplication.shared.open(URL(string: studentLocation.student.mediaURL)!)
        }
        else {
            self.showAlertMessage("It is not possible open this link.")
        }
    }

    @IBAction func refreshPressed(_ sender: Any) {
        OTMClient.sharedInstance().getUsersLocation(isReload: true) { (students, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.showAlertMessage(error)
                } else if students.count > 0 {
                    self.students = students
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        OTMClient.sharedInstance().logout { (success, error) in
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "goToAddPinSegue" {
            if OTMDataSource.sharedInstance().locationObjectId != "" {
                let alertController = UIAlertController(title: nil, message: "You Have Already Posted a Student Location. Would You Like to Overwrite Your Current Location?", preferredStyle: .alert)
                
                let alertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                let overwriteAction = UIAlertAction(title: "Overwrite", style: .default, handler: { (action) in
                    self.performSegue(withIdentifier: "goToAddPinSegue", sender: nil)
                })
                
                alertController.addAction(overwriteAction)
                alertController.addAction(alertAction)
                
                self.present(alertController, animated: true, completion: nil)
                
                return false
            }
        }
        
        return true
    }
    
    func showAlertMessage(_ message: String){
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alertController.addAction(alertAction)
        
        self.present(alertController, animated: true, completion: nil)
    }

}
