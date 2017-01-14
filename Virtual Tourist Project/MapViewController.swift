//
//  MapViewController.swift
//  Virtual Tourist Project
//
//  Created by Ashton Morgan on 1/3/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deleteLbl: UILabel!
    
    var stack: CoreDataStack!
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        stack = appDel.stack
        
        navigationItem.rightBarButtonItem = editButtonItem
        
        mapView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_:))))
        
        deleteLbl.isHidden = true
        centerMap()
        loadPins()
    }
    
    
    
    func longPressed(_ longPress: UIGestureRecognizer) {
        
        if !isEditing {
            if longPress.state == .began {
                let point = longPress.location(in: self.mapView)
                let location = mapView.convert(point, toCoordinateFrom: mapView)
                addNewPin(locationForPoint: location)
            }
        }
        
        stack.save()
    }

    func addNewPin(locationForPoint location: CLLocationCoordinate2D) {
        let pin = Pin(latitude: location.latitude, longitude: location.longitude, context: stack.mainContext)
        let annotation = NewPin(title: nil, subtitle: nil, coord: location, objectID: pin.objectID)
        mapView.addAnnotation(annotation)
    }
    
    func loadPins() {
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        do{
            if let pinArray = try? stack.mainContext.fetch(fetch) as! [Pin] {
                
                var newPinArr = [NewPin]()
                
                for pin in pinArray {
                    let lat = CLLocationDegrees(pin.latitude!)
                    let lon = CLLocationDegrees(pin.longitude!)
                    let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    
                    newPinArr.append(NewPin(title: nil, subtitle: nil, coord: coord, objectID: pin.objectID))
                }
                mapView.addAnnotations(newPinArr)
            }
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        deleteLbl.isHidden = !editing
    }
    
    
    func saveMapPosition() {
        
        userDefaults.set(mapView.region.center.latitude, forKey: "latitude")
        userDefaults.set(mapView.region.center.longitude, forKey: "longitude")
        userDefaults.set(mapView.region.span.latitudeDelta, forKey: "latDelta")
        userDefaults.set(mapView.region.span.longitudeDelta, forKey: "lonDelta")
        
    }
    
    func centerMap() {
        
        if let lat = userDefaults.object(forKey: "latitude") as? CLLocationDegrees,
            let lon = userDefaults.object(forKey: "longitude") as? CLLocationDegrees,
            let latDelta = userDefaults.object(forKey: "latDelta") as? CLLocationDegrees,
            let lonDelta = userDefaults.object(forKey: "lonDelta") as? CLLocationDegrees {
            
            mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2D(latitude: lat, longitude: lon), MKCoordinateSpanMake(latDelta, lonDelta))
            
        }
    }
}
