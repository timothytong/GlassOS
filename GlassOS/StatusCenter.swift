//
//  StatusCenter.swift
//  GlassOS
//
//  Created by Timothy Tong on 2015-01-06.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

import UIKit
// This will be a singleton.
class StatusCenter{
    private var statusQueue:Array<Dictionary<String, Any>>!
    private var aStatusIsActive = false
    let screenSize = Constants.screenSize()
    
    class var sharedInstance: StatusCenter{
        struct Static{
            static var instance: StatusCenter?
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&Static.token, { () -> Void in
            Static.instance = StatusCenter()
        })
        return Static.instance!
    }
    
    func displayStatus(msg: String){
        if statusQueue == nil{
            statusQueue = [Dictionary<String, Any>]()
        }
        var rectSize = msg.boundingRectWithSize(CGSizeMake(self.screenSize.width / 3, 0), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Thin", size: 25)!], context: nil).size
        if !aStatusIsActive{
            aStatusIsActive = true
            let appDel = UIApplication.sharedApplication().delegate as AppDelegate
            appDel.displayStatus(msg, labelSize: rectSize)
        }
        else{
            var newDict = [String:Any]()
            newDict.updateValue(msg, forKey: "message")
            newDict.updateValue(rectSize, forKey: "size")
            statusQueue.append(newDict)
        }
    }
    
    func aStatusHasBeenDismissed(){
        aStatusIsActive = false
        if !statusQueue.isEmpty{
            let dict = statusQueue.removeAtIndex(0) as Dictionary
            var message = dict["message"] as String
            var size = dict["size"] as CGSize
            let appDel = UIApplication.sharedApplication().delegate as AppDelegate
            appDel.displayStatus(message, labelSize: size)
        }
        else{
            aStatusIsActive = false
            let appDel = UIApplication.sharedApplication().delegate as AppDelegate
            appDel.dismissStatusWindow()

        }
    }
    
    func displayImportantStatus(msg: String){
        
    }
    

}
