//
//  MapViewController.swift
//  On The Map
//
//  Created by Flavio Kreis on 14/02/17.
//  Copyright © 2017 Flavio Kreis. All rights reserved.
//

import UIKit
import MapKit

class StudentsMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        OTMClient.sharedInstance().getUsersLocation(isReload: false) { (students, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.showAlertMessage(error)
                } else if students.count > 0 {
                    self.addAnnotationsByStudentsLocation(students)
                }
            }
        }
    }
    
    func addAnnotationsByStudentsLocation(_ studentsLocation: [StudentLocation]){
        let actualAnnotations = self.mapView.annotations
        
        if actualAnnotations.count > 0 {
            self.mapView.removeAnnotations(actualAnnotations)
        }
        
        var annotations = [MKPointAnnotation]()
        
        for studentLocation in studentsLocation {
            let annotation = MKPointAnnotation()
            annotation.coordinate = studentLocation.location.coordinate
            annotation.title = studentLocation.student.fullName
            annotation.subtitle = studentLocation.student.mediaURL
            
            annotations.append(annotation)
        }
        
        self.mapView.addAnnotations(annotations)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let toOpen = view.annotation?.subtitle! {
                if UIApplication.shared.canOpenURL(URL(string: toOpen)!){
                    UIApplication.shared.open(URL(string: toOpen)!)
                }
                else {
                    self.showAlertMessage("It is not possible open this link.")
                }
            }
        }
    }
    
    func showAlertMessage(_ message: String){
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alertController.addAction(alertAction)
        
        self.present(alertController, animated: true, completion: nil)
    }

    @IBAction func refreshPressed(_ sender: Any) {
        OTMClient.sharedInstance().getUsersLocation(isReload: true) { (students, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.showAlertMessage(error)
                } else if students.count > 0 {
                    self.addAnnotationsByStudentsLocation(students)
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

}
