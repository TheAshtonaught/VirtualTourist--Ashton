//
//  ApiConvience.swift
//  Virtual Tourist Project
//
//  Created by Ashton Morgan on 1/1/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import Foundation

class ApiConvience {
   
    var session: URLSession! = nil
    var apiConstants = ApiConstants()
    
    // initializer that accepts apiConstants
    
    init(apiConstants: ApiConstants) {
        newSession(apiConstants: apiConstants)
    }
    
    // a way to start new session after using invalidateAndCancel method to stop pending task
    func newSession(apiConstants: ApiConstants) {
        
        
        self.session = URLSession(configuration: URLSessionConfiguration.default)
        
        self.apiConstants.scheme = apiConstants.scheme
        self.apiConstants.host = apiConstants.host
        self.apiConstants.path = apiConstants.path
        self.apiConstants.domain = apiConstants.domain
    }
    
    // MARK: Build URL
    
    func apiUrlWithMethod(method: String?, PathExtension: String? = nil, parameters:[String:AnyObject]? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = apiConstants.scheme
        components.host = apiConstants.host
        components.path = apiConstants.path + (method ?? "") + (PathExtension ?? "")
        
        if let parameters = parameters {
            components.queryItems = [NSURLQueryItem]() as [URLQueryItem]?
            for (key, value) in parameters {
                let queryItem = NSURLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem as URLQueryItem)
            }
        }
        
        return components.url! as NSURL
    }
    
    // MARK: Make Request
    
    func apiRequest(url: NSURL, method: String, headers: [String:String]? = nil, body: [String:AnyObject]? = nil, completionHandler: @escaping (Data?, NSError?) -> Void) {
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = method
        
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let body = body {
            request.httpBody = try! JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions())
        }
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if let error = error {
                completionHandler(nil, error as NSError?)
                return
            }
            
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if (statusCode < 200 && statusCode > 299) {
                    let userInfo = [
                        NSLocalizedDescriptionKey: "Bad Response"
                    ]
                    let error = NSError(domain: "API", code: statusCode, userInfo: userInfo)
                    completionHandler(nil, error)
                    return
                }
            }
            completionHandler(data, nil)
        }
        task.resume()
    
    }
    
    func dropAllTask(apiConstants: ApiConstants) {
        session.invalidateAndCancel()
        newSession(apiConstants: apiConstants)
    }
    
    // helper function to return errors
    
    func errorReturn(code: Int, description: String, domain: String)-> NSError {
        let userInfo = [NSLocalizedDescriptionKey: description]
        return NSError(domain: domain, code: code, userInfo: userInfo)
    }

}
