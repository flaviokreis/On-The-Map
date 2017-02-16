//
//  LocationModel.swift
//  On The Map
//
//  Created by Flavio Kreis on 14/02/17.
//  Copyright © 2017 Flavio Kreis. All rights reserved.
//

import MapKit

struct LocationModel {
    let latitude: Double
    let longitude: Double
    let mapString: String
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
}
