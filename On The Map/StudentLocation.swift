//
//  StudentLocation.swift
//  On The Map
//
//  Created by Flavio Kreis on 14/02/17.
//  Copyright © 2017 Flavio Kreis. All rights reserved.
//

import Foundation

struct StudentLocation {
    let student: Student
    let location: LocationModel
    let objectID: String
    
    init(student: Student, location: LocationModel, objectID: String) {
        self.student = student
        self.location = location
        self.objectID = objectID
    }
    
    init(dictionary: [String : AnyObject]) {
        objectID = dictionary[OTMClient.JSONResponseKeys.objectID] as? String ?? ""
        
        let firstName = dictionary[OTMClient.JSONResponseKeys.firstName] as? String ?? ""
        let lastName = dictionary[OTMClient.JSONResponseKeys.lastName] as? String ?? ""
        let uniqueKey = dictionary[OTMClient.JSONResponseKeys.uniqueKey] as? String ?? ""
        let mediaURL = dictionary[OTMClient.JSONResponseKeys.mediaURL] as? String ?? ""
        student = Student(uniqueKey: uniqueKey, firstName: firstName, lastName: lastName, mediaURL: mediaURL)
        
        let latitude = dictionary[OTMClient.JSONResponseKeys.latitude] as? Double ?? 0.0
        let longitude = dictionary[OTMClient.JSONResponseKeys.longitude] as? Double ?? 0.0
        
        let mapString = dictionary[OTMClient.JSONResponseKeys.mapString] as? String ?? ""
        location = LocationModel(latitude: latitude, longitude: longitude, mapString: mapString)
    }
    
}
