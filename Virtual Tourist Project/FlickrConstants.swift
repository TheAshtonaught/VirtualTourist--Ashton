//
//  FlickrConstants.swift
//  Virtual Tourist Project
//
//  Created by Ashton Morgan on 1/2/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

extension FlickrConvience {
    
    struct Components {
        static let Scheme = "https"
        static let Host = "api.flickr.com"
        static let Path = "/services/rest"
    }
    
    struct JSONResponseKeys {
        static let status = "stat"
        static let title = "title"
        static let mediumURL = "url_m"
        static let mediumHeight = "height_m"
        static let mediumWidth = "width_m"
        static let pages = "pages"
        static let photos = "photos"
        static let photo = "photo"
        static let total = "total"
        static let message = "message"
    }
    
    struct ParametersKeys {
        static let method = "method"
        static let safeSearch = "safe_search"
        static let text = "text"
        static let bbox = "bbox"
        static let apiKey = "api_key"
        static let galleryId = "gallery_id"
        static let extras = "extras"
        static let format = "format"
        static let noJSONCallback = "nojsoncallback"
        static let page = "page"
        static let perPage = "per_page"
        static let geoContext = "geo_context"
    }
    
    struct ParameterValues {
        static let searchMethod = "flickr.photos.search"
        
        static let apiKey = "83d8904798d38e7032665ded116d5bda"
        static let responseFormat = "json"
        static let mediumURL = "url_m"
    }
    
    struct BBox {
        static let halfWidth = 1.0
        static let halfHeight = 1.0
        static let latitudeRange = (-90.0, 90.0)
        static let longitudeRange = (-180.0, 180.0)
    }
}
