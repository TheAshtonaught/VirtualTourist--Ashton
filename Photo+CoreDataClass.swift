//
//  Photo+CoreDataClass.swift
//  Virtual Tourist Project
//
//  Created by Ashton Morgan on 1/1/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import Foundation
import CoreData
import UIKit


public class Photo: NSManagedObject {

    var image: UIImage? {
        get{
            if let imageData = imageData {
                return UIImage(data: imageData as Data)
            }else {
                return nil
            }
        }
    }
    
    convenience init(title: String, image: UIImage, context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: entity, insertInto: context)
            self.title = title
            self.path = "N/A"
            self.imageData = UIImagePNGRepresentation(image) as NSData?
        } else {
            fatalError("unable to find entity name!")
        }
    }
    
    convenience init(dictionary: [String:AnyObject], context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: entity, insertInto: context)
            self.title = dictionary[FlickrConvience.JSONResponseKeys.title] as? String
            self.path = dictionary[FlickrConvience.JSONResponseKeys.mediumURL] as? String
            
        } else {
            fatalError("Entity name N/A")
        }
    }
    
    static func photosFromDictArray(dictionaries: [[String:AnyObject]], context: NSManagedObjectContext) -> [Photo] {
        var photos = [Photo]()
        for photoDict in dictionaries {
            photos.append(Photo(dictionary: photoDict, context: context))
        }
        let sortedPhotos = photos.sorted(by: { $0.path! < $1.path! })
        return sortedPhotos
    }
    
    
}
