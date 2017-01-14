//
//  Pin+CoreDataClass.swift
//  Virtual Tourist Project
//
//  Created by Ashton Morgan on 1/1/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import Foundation
import CoreData


public class Pin: NSManagedObject {
    
    convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        
        if let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            self.init(entity: entity, insertInto: context)
            self.latitude = latitude as NSNumber?
            self.longitude = longitude as NSNumber?
        } else {
            fatalError("could not find entity name")
        }
    }
    
    func deletePhotos(context: NSManagedObjectContext) {
        if let photos = photos {
            for photo in photos {
                context.delete(photo as! NSManagedObject)
            }
        }
    }

}
