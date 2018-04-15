//
//  DetailViewController.swift
//  CobaltTest
//
//  Created by Antonio Strijdom on 11/04/2018.
//  Copyright © 2018 Antonio Strijdom. All rights reserved.
//

import UIKit

/// View controller for displaying Marvel character details
class DetailViewController: UIViewController {

    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    
    var detailItem: MarvelCharacter? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            navigationItem.title = detail.name
            
            if let bgImageView = backgroundImageView,
                let thumbImageView = thumbnailImageView {
                detail.thumbImage { (image) in
                    bgImageView.image = image
                    thumbImageView.image = image
                }
            }
            
            if let descTextView = descriptionTextView {
                descTextView.text = detail.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

