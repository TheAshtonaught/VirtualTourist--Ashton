//
//  PinPhotosViewController.swift
//  Virtual Tourist Project
//
//  Created by Ashton Morgan on 1/3/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PinPhotosViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionBtn: UIBarButtonItem!
    @IBOutlet weak var collectionActivityIndicator: UIActivityIndicatorView!
    
    var stack: CoreDataStack!
    var pin: Pin!
    var photoArr = [Photo]()
    var flickrClient = FlickrConvience.sharedClient()
    var indexArr = [NSIndexPath]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        stack = appDel.stack
        
        collectionActivityIndicator.isHidden = false
        collectionActivityIndicator.startAnimating()
        
        configureMap()
        
        if photoArr.count == 0 {
            newCollectionBtn.isEnabled = false
            newPhotoCollection()
        }
    }
    
    override func viewDidLayoutSubviews() {
        
        configureCollectionViewLayout()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        flickrClient.apiConvience.dropAllTask(apiConstants: ApiConstants(scheme: FlickrConvience.Components.Scheme, host: FlickrConvience.Components.Host, path: FlickrConvience.Components.Path, domain: "FlickrClient"))
    }

    func configureMap() {
        
        if let mapView = mapView, let pin = pin {
            let coord = CLLocationCoordinate2D(latitude: CLLocationDegrees(pin.latitude!), longitude: CLLocationDegrees(pin.longitude!))
            let region = MKCoordinateRegionMake(coord, MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3))
            mapView.setRegion(region, animated: true)
            
            let point = MKPointAnnotation()
            point.coordinate = coord
            mapView.addAnnotation(point)
            
        }
    }
    
    func configureCollectionViewLayout() {
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing  = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let size = (collectionView.frame.size.width/3)
        layout.itemSize = CGSize(width: size, height: size)
        collectionView.collectionViewLayout = layout
        
    }
    
    func changeCollectionBtn() {
        if indexArr.count > 0 {
            newCollectionBtn.title = "Delete Selected Photos"
        } else {
            newCollectionBtn.title = "New Collection"
        }
    }
    
    @IBAction func newCollectionBtnPressed(_ sender: Any) {
        
        collectionActivityIndicator.isHidden = false
        collectionActivityIndicator.startAnimating()
        
        if indexArr.isEmpty {
            pin.deletePhotos(context: stack.mainContext)
            photoArr.removeAll(keepingCapacity: true)
            collectionView.reloadData()
            
            newPhotoCollection()
        } else {
            deleteSelectedPhoto()
        }
        
        changeCollectionBtn()
    }

    func newPhotoCollection() {
        
        flickrClient.getPhotosAtLoc(pin: pin, context: stack.mainContext) {(photoArr, error) in
            
            guard error == nil else {
                print(error!)
                return
            }
            
            if let photoArr = photoArr {
                for photo in photoArr {
                    photo.pin = self.pin
                }
                DispatchQueue.main.async {
                    self.photoArr = photoArr
                    self.stack.save()
                }
                
                self.collectionView.reloadData()
                self.newCollectionBtn.isEnabled = true
            }
        }
    }
        
    func deleteSelectedPhoto() {
            
            
            // Credit: Stack Exchange
            var photoToDelete = [Photo]()
            collectionView.performBatchUpdates({
                
                let indexes = self.indexArr.sorted(by: {$0.row > $1.row})
                
                for index in indexes {
                    let photo = self.photoArr[index.row]
                    self.photoArr.remove(at: index.row)
                    self.collectionView.deleteItems(at: [index as IndexPath])
                    photoToDelete.append(photo)
                }
                
            }
                , completion: { (completed) in
                    if self.photoArr.count == 0 {
                        DispatchQueue.main.async {
                            self.stack.save()
                        }
                    }
            })
            for p in photoToDelete {
                stack.mainContext.delete(p)
            }
            
            indexArr = [NSIndexPath]()
        }
        
}
