//
//  OTMConstants.swift
//  On The Map
//
//  Created by Flavio Kreis on 13/02/17.
//  Copyright © 2017 Flavio Kreis. All rights reserved.
//

import UIKit

extension OTMClient {
    
    // MARK: Constants
    struct Constants {
        
        // MARK: URLs
        static let ApiScheme = "https"
    }
    
    struct Udacity {
        static let Host = "www.udacity.com"
        static let SessionPath = "/api/session"
        static let UserPath = "/api/users/"
        
        static let SignUpUrl = URL(string: "https://www.udacity.com/account/auth#!/signup")
    }
    
    struct Parser {
        static let Host = "parse.udacity.com"
        static let StudentLocationPath = "/parse/classes/StudentLocation/"
        
        static let ApplicationId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let apiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    }
    
    struct JSONResponseKeys {
        static let account = "account"
        static let key = "key"
        static let user = "user"
        static let error = "error"
        static let results = "results"
        static let objectID = "objectId"
        static let updatedAt = "updatedAt"
        static let uniqueKey = "uniqueKey"
        static let firstName = "firstName"
        static let first_name = "first_name"
        static let last_name = "last_name"
        static let lastName = "lastName"
        static let mediaURL = "mediaURL"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let mapString = "mapString"
    }
    
    struct RequestParams {
        static let udacity = "udacity"
        static let username = "username"
        static let password = "password"
        static let limit = "limit"
        static let order = "order"
        static let udpatedAt = "updatedAt"
        static let where_ = "where"
        static let uniqueKey = "uniqueKey"
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let mediaURL = "mediaURL"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let mapString = "mapString"
    }
}
