//
//  OTMDataSource.swift
//  On The Map
//
//  Created by Flavio Kreis on 14/02/17.
//  Copyright © 2017 Flavio Kreis. All rights reserved.
//

import UIKit

class OTMDataSource: NSObject {
    
    var user: Student? = nil
    var studentLocations = [StudentLocation]()
    var locationObjectId = ""
    var isSaved = false
    
    class func sharedInstance() -> OTMDataSource {
        struct Singleton {
            static var sharedInstance = OTMDataSource()
        }
        return Singleton.sharedInstance
    }

}
