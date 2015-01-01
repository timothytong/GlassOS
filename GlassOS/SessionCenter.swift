//
//  SessionCenter.swift
//  GlassOS
//
//  Created by Timothy Tong on 2014-12-22.
//  Copyright (c) 2014 Timothy Tong. All rights reserved.
//

import Foundation
enum functionMode{
    case functionModeTranslation
    case functionModeCamera
    case functionModeEmail
    case functionModeSettings
}
class SessionCenter: NSObject {
    private var userFullControl = false //Will be used to determine if the user is allowed to perform Myo gestures
    var activeMode: functionMode?

    class var sharedInstance: SessionCenter{
        struct Static{
            static var instance: SessionCenter?
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&Static.token, { () -> Void in
            Static.instance = SessionCenter()
        })
        return Static.instance!
    }
    
    func updateActiveMode(newMode: functionMode!){
        activeMode = newMode
    }
    
    func enableFullControl(){
        userFullControl = true
    }
    
    func disableFullControl(){
        userFullControl = false
    }
}
