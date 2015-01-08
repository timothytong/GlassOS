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
    private var imStatusQueue:Array<Dictionary<String, Any>>!
    private var aStatusIsActive = false
    private var canShowNormalStatus = true
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
        if canShowNormalStatus{
            if statusQueue == nil{
                statusQueue = [Dictionary<String, Any>]()
            }
            let appDel = UIApplication.sharedApplication().delegate as AppDelegate
            var rectSize = msg.boundingRectWithSize(CGSizeMake(self.screenSize.width / 2, 0), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Thin", size: 25)!], context: nil).size
            if !aStatusIsActive{
                aStatusIsActive = true
                appDel.displayStatus(msg, labelSize: rectSize, isImportant: false)
            }
            else{
                var newDict = [String:Any]()
                newDict.updateValue(msg, forKey: "message")
                newDict.updateValue(rectSize, forKey: "size")
                statusQueue.append(newDict)
            }
            
        }
    }
    
    func aStatusHasBeenDismissed(){
        aStatusIsActive = false
        let appDel = UIApplication.sharedApplication().delegate as AppDelegate
        if !canShowNormalStatus{
            if imStatusQueue.isEmpty{
                println("imStatus queue is empty.")
                canShowNormalStatus = true
                appDel.dismissStatusWindow()
            }
            else{
                let dict = imStatusQueue.removeAtIndex(0) as Dictionary
                var message = dict["message"] as String
                var size = dict["size"] as CGSize
                println("imStatus queue is not empty, message is \(message)")
                appDel.displayStatus(message, labelSize: size, isImportant: true)
            }
        }
        else{
            if !statusQueue.isEmpty{
                let dict = statusQueue.removeAtIndex(0) as Dictionary
                var message = dict["message"] as String
                var size = dict["size"] as CGSize
                appDel.displayStatus(message, labelSize: size, isImportant: false)
            }
            else{
                aStatusIsActive = false
                appDel.dismissStatusWindow()
            }
        }
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func displayImportantStatus(msg: String){
        clearQueue()
        if imStatusQueue == nil{
            imStatusQueue = [Dictionary<String, Any>]()
        }
        canShowNormalStatus = false
        var rectSize = msg.boundingRectWithSize(CGSizeMake(self.screenSize.width - 10, 0), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Thin", size: 25)!], context: nil).size
        let appDel = UIApplication.sharedApplication().delegate as AppDelegate
        appDel.dismissStatusWindow()
        
        delay(3, closure: { () -> () in
            appDel.displayStatus(msg, labelSize: rectSize, isImportant: true)
        })
    }
    
    func clearQueue(){
        statusQueue.removeAll(keepCapacity: false)
    }
    
    
}
