//
//  NewPin.swift
//  Virtual Tourist Project
//
//  Created by Ashton Morgan on 1/4/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class NewPin: NSObject, MKAnnotation {
    
    let title: String?
    let subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String?, subtitle: String?, coord: CLLocationCoordinate2D, objectID: NSManagedObjectID) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coord
        super.init()
    }
}
