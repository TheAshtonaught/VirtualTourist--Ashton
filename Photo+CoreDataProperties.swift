//
//  Photo+CoreDataProperties.swift
//  Virtual Tourist Project
//
//  Created by Ashton Morgan on 1/1/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var imageData: NSData?
    @NSManaged public var path: String?
    @NSManaged public var title: String?
    @NSManaged public var pin: Pin?

}
