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
        "safe_search": "1",
        "extras": "url_m",
        "format": "json",
        "nojsoncallback": "1"
    ]
    
    var urlString: String {
        var result = ""
        for (varName, value) in self.keyValuePairs {
            let encodedValue = value.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            result += "\(varName)=\(encodedValue)&"
        }
        return "\(self.baseURL)?\(result)"
    }
    
    @IBAction func searchPhotosByPhraseTouchUp(sender: UIButton) {
        let session = NSURLSession.sharedSession()
        println("\(urlString)")
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
                    if let photoArray = photosDictionary["photo"] as? [[String: AnyObject]] {
                            println("\(photoArray.count)")
                        let index = Int(arc4random_uniform(UInt32(photoArray.count)))
                        let photo = photoArray[index] as [String: AnyObject]
                        println(photo["url_m"] as! String)
                        let imageURL = NSURL(string: photo["url_m"] as! String)
                        if let imageData = NSData(contentsOfURL: imageURL!) {
                            println("printing image")
                        } else {
                            println("no image to print")
                        }
                    }
                }
            }
        }
        task.resume()
        
    }
}

