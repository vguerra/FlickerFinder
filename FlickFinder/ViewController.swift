//
//  ViewController.swift
//  FlickFinder
//
//  Created by Victor Guerra on 21/04/15.
//  Copyright (c) 2015 Victor Guerra. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var FlickerImage: UIImageView!

    @IBOutlet weak var searchFlickerByPhrase: UIButton!
    @IBOutlet weak var searchFlickerByLatLong: UIButton!
    
    
    @IBOutlet weak var phraseText: UITextField!
    @IBOutlet weak var latitudeText: UITextField!
    @IBOutlet weak var longitudText: UITextField!
    @IBOutlet weak var statusText: UILabel!
    
}

