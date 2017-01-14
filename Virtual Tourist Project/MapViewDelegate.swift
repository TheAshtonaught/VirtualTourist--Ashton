//
//  MapViewDelegate.swift
//  Virtual Tourist Project
//
//  Created by Ashton Morgan on 1/6/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//
import MapKit
import CoreData

extension MapViewController: MKMapViewDelegate {
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        var pin: Pin!
        do {
            let annotation = view.annotation as! NewPin
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
            let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", argumentArray: [annotation.coordinate.latitude, annotation.coordinate.longitude])
            fetch.predicate = predicate
            let pinArr = try stack.mainContext.fetch(fetch) as? [Pin]
            pin = pinArr![0]
        } catch let err as NSError {
            print("could not get pin \(err.localizedDescription)")
            return
        }
        
        
        if self.isEditing {
            mapView.removeAnnotation(view.annotation!)
            stack.mainContext.delete(pin)
            stack.save()
            return
        }
        
        let pinPhotoVC = storyboard!.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PinPhotosViewController
        
        pinPhotoVC.pin = pin
        
        if let photoArr = pin!.photos?.allObjects as? [Photo] {
            pinPhotoVC.photoArr = photoArr.sorted(by: { $0.path! < $1.path! })
        }
        
        navigationController?.pushViewController(pinPhotoVC, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapPosition()
    }
}
