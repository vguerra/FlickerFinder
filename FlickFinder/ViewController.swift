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

    @IBOutlet weak var phraseText: UITextField!
    @IBOutlet weak var latitudeText: UITextField!
    @IBOutlet weak var longitudText: UITextField!
    @IBOutlet weak var statusText: UILabel!

    let baseURL = "https://api.flickr.com/services/rest/"
    let keyValuePairs = [
        "method": "flickr.photos.search",
        "api_key": "***REMOVED***",
        "text": "baby+asian+elephant",
        "format": "json",
        "nojsoncallback": "1"
    ]
    
    var urlString: String {
        var result = ""
        for (varName, value) in self.keyValuePairs {
            result += "\(varName)=\(value)&"
        }
        return "\(self.baseURL)?\(result)"
    }
    
    @IBAction func searchPhotosByPhraseTouchUp(sender: UIButton) {
        let session = NSURLSession.sharedSession()
        let urlComponent = NSURLComponents(string: urlString)
        let request = NSURLRequest(URL: urlComponent!.URLRelativeToURL(nil)!)

        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
        
            if let error = downloadError {
                println("error: \(error)")
            } else {
                var parsingError: NSError? = nil
                let parsedResult: AnyObject! = NSJSONSerialization.JSONObjectWithData(data,
                    options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
                if let photosDictionary = parsedResult.valueForKey("photos") as? NSDictionary {
                    if let photoArray = photosDictionary.valueForKey("photo") as? [[String: AnyObject]] {
                            println("\(photoArray)")
                    }
                }
            }
        }
        task.resume()
        
    }
}

