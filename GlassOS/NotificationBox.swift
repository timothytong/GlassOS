//
//  NotificationBox.swift
//  GlassOS
//
//  Created by Timothy Tong on 2014-12-12.
//  Copyright (c) 2014 Timothy Tong. All rights reserved.
//

import UIKit
import Foundation

@objc protocol NotificationBoxDelegate{
    func notificationBoxDidDisappear()
}

class NotificationBox: UIView {
    var message:String!
    var msgLabel:UILabel!
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        alpha = 0.7
        message = ""
        backgroundColor = UIColor.whiteColor()
        msgLabel = UILabel(frame: CGRectMake(10, 5, frame.width-20, frame.height-10))
        msgLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 20)
        msgLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        msgLabel.numberOfLines = 0
        msgLabel.clipsToBounds = true
        addSubview(msgLabel)
        var tap = UITapGestureRecognizer(target: self, action: "show")
        addGestureRecognizer(tap)
    }
    func setLabel(string:String){
        msgLabel.text = string
    }
    
    func notificationClicked(){
        // TODO
    }
    
    func show(){
        alpha = 0
        frame = CGRectMake(frame.origin.x, frame.origin.y - 30, frame.width, frame.height)
        UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.alpha = 0.7
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + 30, self.frame.width, self.frame.height)
            }) { (complete) -> Void in
                let timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "hide", userInfo: nil, repeats: false)
        }
    }
    
    func hide(){
        println("hiding")
        UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.alpha = 0
            }) { (complete) -> Void in
        }
    }
}
