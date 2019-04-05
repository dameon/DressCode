//
//  MainViewController.swift
//  DressCode
//
//  Created by Huynh Danh on 9/8/16.
//  Copyright © 2016 Dameon D Bryant. All rights reserved.
//

import UIKit
import CloudKit
import SDWebImage

class ClosetViewController: UIViewController {
    
    // MARK: Properties
    
    var topItems: [CKRecord] = []
    var bottomItems: [CKRecord] = []
    var shoesItems: [CKRecord] = []
    
    var popupVC: PopupViewController!
    
    // MARK: Outlets
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var clothsView: UIView!
    
    @IBOutlet weak var topCollectionView: UICollectionView!
    @IBOutlet weak var bottomCollectionView: UICollectionView!
    @IBOutlet weak var shoesCollectionView: UICollectionView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var topGestureRecognizer: UILongPressGestureRecognizer!
    @IBOutlet weak var bottomGestureRecognizer: UILongPressGestureRecognizer!
    @IBOutlet weak var shoesGestureRecognizer: UILongPressGestureRecognizer!
    
    // MARK: Actions
    
    @IBAction func share(_ sender: UIBarButtonItem) {
        
        let text = "Hey, I'm thinking of wearing this today. What do you think?"
        let image = UIImage(view: clothsView)
        
        let items: [Any] = [text, image]
        
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityVC.popoverPresentationController?.barButtonItem = sender
        activityVC.excludedActivityTypes = [.airDrop, .addToReadingList]
        
        present(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func showItem(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            
            var collectionView: UICollectionView!
            var records: [CKRecord] = []
            
            switch sender {
            case topGestureRecognizer:
                collectionView = topCollectionView
                records = topItems
            case bottomGestureRecognizer:
                collectionView = bottomCollectionView
                records = bottomItems
            case shoesGestureRecognizer:
                collectionView = shoesCollectionView
                records = shoesItems
            default: break
            }
            
            let location = sender.location(in: collectionView)
            if let indexPath = collectionView.indexPathForItem(at: location) {
                
                // prepare data
                let cell = collectionView.cellForItem(at: indexPath) as! ItemCell
                let record = records[indexPath.item]
                
                popupVC = storyboard?.instantiateViewController(withIdentifier: "PopupViewController") as! PopupViewController
                
                // config
                popupVC.itemDescription = record.object(forKey: "itemDescription") as? String
                popupVC.photo = cell.itemImage.image
                
                // add popup view
                view.addSubview(popupVC.view)
                popupVC.view.frame = view.frame
                popupVC.view.didMoveToSuperview()
            }
        } else if sender.state == .ended {
            
            if popupVC == nil { return }
            
            // remove popup view
            popupVC.view.removeFromSuperview()
            popupVC = nil
        }
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        
        fetchData()
    }
    
    func fetchData() {
        clearData()
        
        activityIndicator.startAnimating()
        shareButton.isEnabled = false
        
        let container = CKContainer.default()
        let publicDatabase = container.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: "ClothingItems", predicate: predicate)
        publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let records = records {
                for record in records {
                    if let type = record.value(forKey: "itemType") as? String {
                        if type == "Top" {
                            self.topItems.append(record)
                        } else if type == "Bottom" {
                            self.bottomItems.append(record)
                        } else if type == "Shoes" {
                            self.shoesItems.append(record)
                        }
                    }
                }
                DispatchQueue.main.async(execute: {
                    self.activityIndicator.stopAnimating()
                    self.shareButton.isEnabled = true
                    
                    self.topCollectionView.reloadData()
                    self.bottomCollectionView.reloadData()
                    self.shoesCollectionView.reloadData()
                })
            }
        }
    }
    
    func clearData() {
        topItems.removeAll()
        bottomItems.removeAll()
        shoesItems.removeAll()
    }
}

extension ClosetViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == topCollectionView {
            return topItems.count
        } else if collectionView == bottomCollectionView {
            return bottomItems.count
        } else if collectionView == shoesCollectionView {
            return shoesItems.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCell
        
        func setImage(_ items: [CKRecord]) {
            let record = items[indexPath.row]
            if let asset = record.value(forKey: "photo") as? CKAsset {
                cell.itemImage.sd_setImage(with: asset.fileURL!)
            }
        }
        
        if collectionView == topCollectionView {
            setImage(topItems)
        } else if collectionView == bottomCollectionView {
            setImage(bottomItems)
        } else if collectionView == shoesCollectionView {
            setImage(shoesItems)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == topCollectionView {
            return topCollectionView.frame.size
        } else if collectionView == bottomCollectionView {
            return bottomCollectionView.frame.size
        } else if collectionView == shoesCollectionView {
            return shoesCollectionView.frame.size
        }
        return CGSize.zero
    }
}

// MARK: - UINavigationBarDelegate

extension ClosetViewController: UINavigationBarDelegate {
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

extension UIImage {
    
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!)
    }
}
