//
//  ViewController.swift
//  FlickFinder
//
//  Created by Victor Guerra on 21/04/15.
//  Copyright (c) 2015 Victor Guerra. All rights reserved.
//

import UIKit

// CONSTANTS
let BASE_URL = "https://api.flickr.com/services/rest/"
let METHOD_NAME = "flickr.photos.search"
let API_KEY = "***REMOVED***"
let EXTRAS = "url_m"
let SAFE_SEARCH = "1"
let DATA_FORMAT = "json"
let NO_JSON_CALLBACK = "1"
let LAT_MIN = -90.0
let LAT_MAX = 90.0
let LON_MIN = -180.0
let LON_MAX = 180.0
let BOX_HALF_SIZE = 1.0


class ViewController: UIViewController {

    @IBOutlet weak var FlickerImage: UIImageView!

    @IBOutlet weak var phraseText: UITextField!
    @IBOutlet weak var latitudeText: UITextField!
    @IBOutlet weak var longitudText: UITextField!
    @IBOutlet weak var statusText: UILabel!
    @IBOutlet weak var searchFlickerLabel: UILabel!
    
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
        self.view.endEditing(true)
    }
    
    @IBAction func searchPhotosByPhraseTouchUp(sender: UIButton) {
        self.dismissAnyVisibleKeyboards()
        
        if phraseText.text.isEmpty {
            showErrorMessage("Can't search for empty phrase!")
            return
        }
        
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
    
    @IBAction func searchPhotosByLatitudLongitudeTouchUp(sender: UIButton) {
        self.dismissAnyVisibleKeyboards()

        if !(isValidLatitude() && isValidLongitude()) {
            return
        }
        
        let keyValuePairs = [
            "method": METHOD_NAME,
            "api_key": API_KEY,
            "bbox": computeBBox(),
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
        notificationCenter.addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyBoardNotifications() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if FlickerImage.image != nil {
            searchFlickerLabel.alpha = 0.0
        }
        self.view.frame.origin.y -= getKeyboardHeight(notification)/2
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if FlickerImage.image != nil {
            searchFlickerLabel.alpha = 1.0
        }
        self.view.frame.origin.y += getKeyboardHeight(notification)/2
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let keyboardSize = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    // MARK: All things regarding http request
    
    func searchFlickerPhotoWithArguments(#methodArguments: [String : AnyObject]) {
        let session = NSURLSession.sharedSession()
        let urlString = BASE_URL + escapedParameters(methodArguments)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            if let error = downloadError {
                println("Error")
            } else {
                var parsingError: NSError? = nil
                let parsedResult: AnyObject! = NSJSONSerialization.JSONObjectWithData(data,
                    options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
                if let photosDictionary = parsedResult.valueForKey("photos") as? [String: AnyObject] {
                    if let totalPages = photosDictionary["pages"] as? Int {
                        let minPages = min(totalPages, 40)
                        let randomPage = Int(arc4random_uniform(UInt32(minPages))) + 1
                        self.searchFlickerPhotoWithArgumentsWithPage(methodArguments: methodArguments, pageNumber: randomPage)
                    }
                }
            }
        }
        task.resume()
    }
    
    func searchFlickerPhotoWithArgumentsWithPage(#methodArguments: [String : AnyObject], pageNumber: Int) {
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
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.statusText.text = "No fotos found!"
                                }
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
    
    // MARK: Utilities
    // computing BBox value
    func computeBBox() -> String {
        let latitude = (latitudeText.text as NSString).doubleValue
        let longitude = (longitudText.text as NSString).doubleValue
    
        let bottom_left_lat = max(latitude - BOX_HALF_SIZE, LAT_MIN)
        let bottom_left_lon = max(longitude - BOX_HALF_SIZE, LON_MIN)
        let top_right_lat = min(latitude + BOX_HALF_SIZE, LAT_MAX)
        let top_right_lon = min(longitude + BOX_HALF_SIZE, LON_MAX)
    
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    
    func isValidLatitude() -> Bool {
        if latitudeText.text.isEmpty {
            showErrorMessage("Please provide a Latitude between -90 and 90)")
            return false
        } else if let latitude = NSNumberFormatter().numberFromString(latitudeText.text) {
            if -90.0 <= Double(latitude) && Double(latitude) <= 90.0 {
                println("is valid")
                return true
            } else {
                showErrorMessage("Latitud is a number but not betwenn -90 and 90")
                return false
            }
        } else {
            showErrorMessage("Latitud should be a number betwenn -90 and 90")
            return false
        }
    }
    
    func isValidLongitude() -> Bool {
        return true
    }
    
    // Giving user's feedback
    func showErrorMessage(textToShow: String) {
        statusText.text = textToShow
    }
}

extension ViewController {
    func dismissAnyVisibleKeyboards() {
        if phraseText.isFirstResponder() || latitudeText.isFirstResponder() || longitudText.isFirstResponder() {
            self.view.endEditing(true)
        }
    }
}

