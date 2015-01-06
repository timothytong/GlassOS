//
//  API.swift
//  GlassOS
//
//  Created by Timothy Tong on 2015-01-05.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

import Foundation

class API{
    class func googleTranslate(aString: String){
        let processedString = aString.stringByReplacingOccurrencesOfString(" ", withString: "%20", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let manager = AFHTTPRequestOperationManager()
        AFNetworkActivityIndicatorManager().enabled = true
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        
        manager.GET(Constants.translationURL(), parameters: aString, success: { (operation, respObj) -> Void in
            var responseString = NSString(data: respObj as NSData, encoding: NSUTF8StringEncoding)
            NSLog(responseString!)
        }) { (operation, error) -> Void in
            println("\(error)")
        }
    }
}
