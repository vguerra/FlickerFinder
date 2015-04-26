//
//  ViewController.swift
//  FlickFinder
//
//  Created by Victor Guerra on 21/04/15.
//  Copyright (c) 2015 Victor Guerra. All rights reserved.
//

import UIKit

let BASE_URL = "https://api.flickr.com/services/rest/"
let METHOD_NAME = "flickr.photos.search"
let API_KEY = "***REMOVED***"
let EXTRAS = "url_m"
let SAFE_SEARCH = "1"
let DATA_FORMAT = "json"
let NO_JSON_CALLBACK = "1"

class ViewController: UIViewController {

    @IBOutlet weak var FlickerImage: UIImageView!

    @IBOutlet weak var phraseText: UITextField!
    @IBOutlet weak var latitudeText: UITextField!
    @IBOutlet weak var longitudText: UITextField!
    @IBOutlet weak var statusText: UILabel!
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Subscribing to keyboard notifications
        subscribeToKeyBoardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // unsuscribing from keyboard notifications
        unsubscribeFromKeyBoardNotifications()
    }
    
    // MARK: Actions
    
    @IBAction func handleTap(recognizer: UITapGestureRecognizer) {
        println("screen was tapped")
    }
    
    @IBAction func searchPhotosByPhraseTouchUp(sender: UIButton) {
        let keyValuePairs = [
            "method": METHOD_NAME,
            "api_key": API_KEY,
            "text": phraseText.text,
            "safe_search": SAFE_SEARCH,
            "extras": EXTRAS,
            "format": DATA_FORMAT,
            "nojsoncallback": NO_JSON_CALLBACK
        ]
        searchFlickerPhotoWithArguments(methodArguments: keyValuePairs)
    }
    
    // MARK: Keyboard notifications
    func subscribeToKeyBoardNotifications() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector("keyBoardWillShow"), name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "keyBoardWillHide", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyBoardNotifications() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
    
    }
    
    func keyboardWillHide(notification: NSNotification) {
    
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let keyboardSize = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    // MARK: All regarding http request 
    
    func searchFlickerPhotoWithArguments(#methodArguments: [String : AnyObject]) {
        let session = NSURLSession.sharedSession()
        let urlString = BASE_URL + escapedParameters(methodArguments)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)

        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
        
            if let error = downloadError {
                println("error: \(error)")
            } else {
                var parsingError: NSError? = nil
                let parsedResult: AnyObject! = NSJSONSerialization.JSONObjectWithData(data,
                    options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
                if let photosDictionary = parsedResult.valueForKey("photos") as? [String: AnyObject] {
                    var totalPhotosValue = 0
                    if let totalPhotos = photosDictionary["total"] as? String {
                        totalPhotosValue = (totalPhotos as NSString).integerValue
                    }
                    if totalPhotosValue > 0 {
                        if let photoArray = photosDictionary["photo"] as? [[String: AnyObject]] {
                            println("\(photoArray.count)")
                            let index = Int(arc4random_uniform(UInt32(photoArray.count)))
                            let photo = photoArray[index] as [String: AnyObject]
                            println(photo)
                            let imageURL = NSURL(string: photo["url_m"] as! String)
                            if let imageData = NSData(contentsOfURL: imageURL!) {
                                let image = UIImage(data: imageData)
                                let title = photo["title"] as! String
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.FlickerImage.image = image
                                    self.statusText.text = title
                                }
                            } else {
                                println("no image to print")
                            }
                        }
                    } else {
                        println("No photos!")
                    }
                }
            }
        }
        task.resume()
        
    }
    
    func escapedParameters(parameters: [String: AnyObject]) -> String {
        var result = [String]()
        for (varName, value) in parameters {
            let encodedValue = value.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            result.append("\(varName)=\(encodedValue)")
        }
        return (!result.isEmpty ? "?" : "") + join("&", result)
    }
}

