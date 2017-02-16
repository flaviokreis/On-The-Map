//
//  AddPinUrlViewController.swift
//  On The Map
//
//  Created by Flavio Kreis on 15/02/17.
//  Copyright © 2017 Flavio Kreis. All rights reserved.
//

import UIKit
import MapKit

class AddPinUrlViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mediaUrlTextField: UITextField!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var location = ""
    var coordinate: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        mediaUrlTextField.delegate = self
        
        addLocationByAddress()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func addLocationByAddress(){
        print("Location: \(location)")
        
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        mapView.isHidden = true
        
        if location != "" {
            let geocoder:CLGeocoder = CLGeocoder();
            geocoder.geocodeAddressString(location) { (placemarks, error) in
                guard error == nil else {
                    self.showAlertMessage("Error on try get the location.")
                    return
                }
                
                self.loadingIndicator.stopAnimating()
                self.loadingIndicator.isHidden = true
                self.mapView.isHidden = false
                
                if let placemarks = placemarks, placemarks.count > 0 {
                    let topResult:CLPlacemark = placemarks[0];
                    let placemark: MKPlacemark = MKPlacemark(placemark: topResult);
                    
                    self.coordinate = (placemark.location?.coordinate)!
                    
                    var region: MKCoordinateRegion = self.mapView.region;
                    region.center = (placemark.location?.coordinate)!;
                    region.span.longitudeDelta *= 0.008;
                    region.span.latitudeDelta *= 0.008;
                    self.mapView.setRegion(region, animated: true);
                    self.mapView.addAnnotation(placemark);
                }
            }
        }
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

    @IBAction func submitPressed(_ sender: Any) {
        
        let dataSource = OTMDataSource.sharedInstance()
        
        dataSource.user?.mediaURL = mediaUrlTextField.text!
        
        let locationModel = LocationModel(latitude: (coordinate?.latitude)!, longitude: (coordinate?.longitude)!, mapString: self.location)
        
        let studentLocation = StudentLocation(student: dataSource.user!, location: locationModel, objectID: dataSource.locationObjectId)
        
        OTMClient.sharedInstance().addOrUpdateStudentLocation(studentLocation) { (success, error) in
            DispatchQueue.main.async {
                if success {
                   self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                }
                else if let error = error {
                    self.showAlertMessage(error)
                }
            }
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func showAlertMessage(_ message: String){
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alertController.addAction(alertAction)
        
        self.present(alertController, animated: true, completion: nil)
    }

}
