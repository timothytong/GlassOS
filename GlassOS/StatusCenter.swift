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
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if self.canShowNormalStatus{
                if self.statusQueue == nil{
                    self.statusQueue = [Dictionary<String, Any>]()
                }
                let appDel = UIApplication.sharedApplication().delegate as AppDelegate
                var rectSize = msg.boundingRectWithSize(CGSizeMake(self.screenSize.width / 2, 0), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Thin", size: 25)!], context: nil).size
                if !self.aStatusIsActive{
                    self.aStatusIsActive = true
                    appDel.displayStatus(msg, labelSize: rectSize, isImportant: false)
                }
                else{
                    var newDict = [String:Any]()
                    newDict.updateValue(msg, forKey: "message")
                    newDict.updateValue(rectSize, forKey: "size")
                    self.statusQueue.append(newDict)
                }
            }
        })
    }
    
    func aStatusHasBeenDismissed(){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.aStatusIsActive = false
            let appDel = UIApplication.sharedApplication().delegate as AppDelegate
            if !self.canShowNormalStatus{
                if self.imStatusQueue.isEmpty{
                    println("imStatus queue is empty.")
                    self.canShowNormalStatus = true
                    appDel.dismissStatusWindow()
                }
                else{
                    let dict = self.imStatusQueue.removeAtIndex(0) as Dictionary
                    var message = dict["message"] as String
                    var size = dict["size"] as CGSize
                    println("imStatus queue is not empty, message is \(message)")
                    appDel.displayStatus(message, labelSize: size, isImportant: true)
                }
            }
            else{
                if !self.statusQueue.isEmpty{
                    let dict = self.statusQueue.removeAtIndex(0) as Dictionary
                    var message = dict["message"] as String
                    var size = dict["size"] as CGSize
                    appDel.displayStatus(message, labelSize: size, isImportant: false)
                }
                else{
                    self.aStatusIsActive = false
                    appDel.dismissStatusWindow()
                }
            }
        })
        
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
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.clearQueue()
            if self.imStatusQueue == nil{
                self.imStatusQueue = [Dictionary<String, Any>]()
            }
            self.canShowNormalStatus = false
            var rectSize = msg.boundingRectWithSize(CGSizeMake(self.screenSize.width - 10, 0), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Thin", size: 25)!], context: nil).size
            let appDel = UIApplication.sharedApplication().delegate as AppDelegate
            appDel.dismissStatusWindow()
            
            self.delay(3, closure: { () -> () in
                appDel.displayStatus(msg, labelSize: rectSize, isImportant: true)
            })
        })
        
    }
    
    func clearQueue(){
        statusQueue.removeAll(keepCapacity: false)
    }
    
    
}
