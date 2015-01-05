//
//  MainController.swift
//  GlassOS
//
//  Created by Timothy Tong on 2014-12-11.
//  Copyright (c) 2014 Timothy Tong. All rights reserved.
//

import UIKit

class MainController: UIViewController {
    var startBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        var welcomelabel = UILabel(frame: CGRectMake(0, 30, self.view.frame.width, 60))
        welcomelabel.text = "Welcome to GlassOS."
        welcomelabel.textAlignment = NSTextAlignment.Center
        welcomelabel.font = UIFont(name: "HelveticaNeue-Thin", size: 35)
        self.view.addSubview(welcomelabel)
        self.startBtn = UIButton(frame: CGRectMake(self.view.frame.width/2 - 50, self.view.frame.height/2 - 20, 100, 40))
        var roundedRectPath = UIBezierPath(roundedRect: CGRectMake(0, 0, self.startBtn.frame.width, self.startBtn.frame.height), cornerRadius: 10)
        var layer = CAShapeLayer()
        layer.path = roundedRectPath.CGPath
        layer.frame = self.startBtn.layer.bounds
        self.startBtn.layer.mask = layer
        self.startBtn.addTarget(self, action: "goPressed", forControlEvents: UIControlEvents.TouchUpInside)
        var startBtnLbl = UILabel(frame: CGRectMake(0, 0, 100, 40))
        startBtnLbl.text = "Go."
        startBtnLbl.textAlignment = NSTextAlignment.Center
        startBtnLbl.font = UIFont(name: "HelveticaNeue-Thin", size: 20)
        startBtnLbl.layer.borderWidth = 0.5
        startBtnLbl.layer.borderColor = UIColor.blackColor().CGColor
        startBtnLbl.layer.cornerRadius = 10
        startBtnLbl.textColor = UIColor.whiteColor()
        startBtnLbl.backgroundColor = UIColor(red: 69/255, green: 69/255, blue: 69/255, alpha: 1)
        self.startBtn.addSubview(startBtnLbl)
        self.view.addSubview(self.startBtn)
    }
    func goPressed(){
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.transitionToCam()
    }
}
