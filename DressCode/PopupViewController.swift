//
//  PopupViewController.swift
//  DressCode
//
//  Created by Huynh Danh on 3/2/17.
//  Copyright © 2017 Dameon D Bryant. All rights reserved.
//

import UIKit

class PopupViewController: UIViewController {
    
    // MARK: Properties
    
    var itemDescription: String!
    var photo: UIImage!
    
    // MARK: Outlets
    
    @IBOutlet weak var popupView: UIView! {
        didSet {
            popupView.layer.cornerRadius = 5.0
        }
    }
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ratioConstraint = NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: imageView, attribute: .height, multiplier: photo.size.width / photo.size.height, constant: 0.0)
        imageView.addConstraint(ratioConstraint)
        
        descriptionLabel.text = itemDescription
        imageView.image = photo
    }
}
