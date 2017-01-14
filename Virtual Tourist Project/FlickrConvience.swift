//
//  FlickrConvience.swift
//  Virtual Tourist Project
//
//  Created by Ashton Morgan on 1/2/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import Foundation
import CoreData

class FlickrConvience {
    
    let apiConvience: ApiConvience
    
    init() {
        let apiConstants = ApiConstants(scheme: Components.Scheme, host: Components.Host, path: Components.Path, domain: "FlickrClient")
        apiConvience = ApiConvience(apiConstants: apiConstants)
    }
    
    fileprivate static var sharedInstance = FlickrConvience()
    class func sharedClient() -> FlickrConvience {
        return sharedInstance
    }
    
    fileprivate func flickrApiRequest(url: NSURL, method: String, body: [String:AnyObject]? = nil, completionHandler: @escaping (_ jsonDict: [String:AnyObject]?, _ error: NSError?) -> Void) {
        
        apiConvience.apiRequest(url: url, method: method, headers: nil, body: nil) { (data, error) in
            
            if let data = data {
                let jsonDict = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                
            
                if let status = jsonDict[JSONResponseKeys.status] as? String, let message = jsonDict[JSONResponseKeys.message] as? String{
                    if status != "ok" {
                        completionHandler(nil, self.apiConvience.errorReturn(code: 0, description: message, domain: "FlickrClient"))
                    }
                    
                } else {
                    completionHandler(jsonDict,nil)
                }
            } else {
                completionHandler(nil, error)
            }
        }
    }
    
    // helper function to grab the number of pages
    func numOfPages(url: NSURL, completionHandler: @escaping (_ pages: Int, _ error: NSError?) -> Void) {
        flickrApiRequest(url: url, method: "GET") { (jsonDict, error) in
            
            guard error == nil else {
                completionHandler(0, error)
                return
            }
            
            if let jsonDict = jsonDict, let photoDict = jsonDict[JSONResponseKeys.photos] as? [String:AnyObject], let totalPages = photoDict[JSONResponseKeys.pages] as? Int {
                completionHandler(totalPages,nil)
                return
            }
        }
    }
    
    func getImageData(photo: Photo, completionhandler: @escaping (_ imageData: NSData?, _ error: NSError?) -> Void) {
        
        let url = NSURL(string: photo.path!)!
        
        apiConvience.apiRequest(url: url, method: "GET") {(data, error) in
        
            guard error == nil else {
                completionhandler(nil, error)
                return
            }
            completionhandler(data as NSData?, nil)
        }
    }
    
    func getPhotosAtLoc(pin: Pin, context: NSManagedObjectContext, completionHandler:@escaping (_ photos: [Photo]?, _ error: NSError?) -> Void) {
        
        var parameters: [String:Any] = [
            ParametersKeys.method: ParameterValues.searchMethod,
            ParametersKeys.apiKey: ParameterValues.apiKey,
            ParametersKeys.bbox: createBBox(lat: Double(pin.latitude!), long: Double(pin.longitude!)),
            ParametersKeys.format: ParameterValues.responseFormat,
            ParametersKeys.noJSONCallback: "1",
            ParametersKeys.extras: ParameterValues.mediumURL,
            ParametersKeys.perPage: "250",
            ParametersKeys.safeSearch: "1"
            ]
        
        let url = apiConvience.apiUrlWithMethod(method: nil, parameters: parameters as [String : AnyObject]?)
        
        numOfPages(url: url) { (pages, error) in
            
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            // get random number to add to page parameter
            let randNum = Int(arc4random_uniform(UInt32(pages)) + 1)
            parameters[ParametersKeys.page] = randNum
            
            let urlForPhoto = self.apiConvience.apiUrlWithMethod(method: nil, parameters: parameters as [String : AnyObject]?)
            
            self.flickrApiRequest(url: urlForPhoto, method: "GET") { (jsonDict, error) in
                
                guard error == nil else {
                    completionHandler(nil, error)
                    return
                }
                
                if let jsonDict = jsonDict, let photosDict = jsonDict[JSONResponseKeys.photos] as? [String:AnyObject],
                    let photoDictArray = photosDict[JSONResponseKeys.photo] as? [[String:AnyObject]] {
                    
                    let maxDictSize = 21
                    // if more than max Dictionaries are returned grab a random set
                    
                    if photoDictArray.count >= maxDictSize {
                        let randIndex = Int(arc4random_uniform(UInt32(photoDictArray.count - maxDictSize)))
                        let rand20 = Array(photoDictArray[randIndex..<randIndex + maxDictSize]) // Credit: Stack Exchange
                        completionHandler(Photo.photosFromDictArray(dictionaries: rand20, context: context), nil)
                    } else {
                        completionHandler(Photo.photosFromDictArray(dictionaries: photoDictArray, context: context), nil)
                    }
                    return
                }
                completionHandler(nil, self.apiConvience.errorReturn(code: 0, description: "Photos not found", domain: "Flickr"))
            }
            
        }
    }
}



extension FlickrConvience {
    // helper function to create bbox
    
    func createBBox(lat: Double, long: Double) -> String {
        let maxiLongitude = min(long + BBox.halfWidth, BBox.longitudeRange.1)
        let maxLatitude = min(lat + BBox.halfHeight, BBox.latitudeRange.1)
        let minLongitude = max(long - BBox.halfWidth, BBox.longitudeRange.0)
        let minLatitude = max(lat - BBox.halfHeight, BBox.latitudeRange.0)
        return "\(minLongitude), \(minLatitude), \(maxiLongitude), \(maxLatitude)"
    }
}
