//
//  CollectionViewDelegate.swift
//  Virtual Tourist Project
//
//  Created by Ashton Morgan on 1/8/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit

extension PinPhotosViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        collectionActivityIndicator.isHidden = true
        collectionActivityIndicator.stopAnimating()
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PinPhotoCollectionViewCell", for: indexPath) as! pinPhotoCollectionViewCell
        let photo = photoArr[indexPath.row]
        
        if let p = photo.image {
            cell.imageView.image = p
        } else {
            cell.imageView.image = UIImage(named: "PlaceholderImage.png")
            cell.activityIndicator.startAnimating()
            cell.activityIndicator.isHidden = false
            
            flickrClient.getImageData(photo: photo, completionhandler: { (imgData, error) in
                
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                
                DispatchQueue.main.async {
                    cell.activityIndicator.stopAnimating()
                    cell.activityIndicator.isHidden = true
                    cell.imageView.image = UIImage(data: imgData! as Data)
                }
                
            })
        }
        
        if (indexArr.contains(indexPath as NSIndexPath)) {
            cell.imageView.alpha = 0.5
        } else {
            cell.imageView.alpha = 1.0
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! pinPhotoCollectionViewCell
        
        if let index = indexArr.index(of: indexPath as NSIndexPath) {
            indexArr.remove(at: index)
            cell.imageView.alpha = 1.0
        } else {
            indexArr.append(indexPath as NSIndexPath)
            cell.imageView.alpha = 0.5
        }
        changeCollectionBtn()
    }
}
