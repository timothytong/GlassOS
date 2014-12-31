//
//  CamHomeController.swift
//  GlassOS
//
//  Created by Timothy Tong on 2014-12-11.
//  Copyright (c) 2014 Timothy Tong. All rights reserved.
//

import UIKit
import AVFoundation

class CamHomeController: UIViewController, CursorDelegate {
    private var captureSession:AVCaptureSession!
    private var captureDevice:AVCaptureDevice?
    private var mainMenu: Menu!
    private var mainMenuArray: Array<NSDictionary>!
    private var cursor: Cursor!
    private var cursorIsVisible = false
    private var selRect: UIView!
    private var startingPoint = CGPointMake(0, 0)
    private var activeUIElements = Dictionary<String, UIView>()
    override func viewDidLoad() {
        super.viewDidLoad()
        println("CamView did load")
        view.backgroundColor = UIColor.whiteColor()
        
        // Main Menu
        // Can add youtube, music, safari etc...
        var helpImg = UIImage(named: "help.png")
        var sel_helpImg = UIImage(named: "help_sel.png")
        var helpDict = NSDictionary(objects: NSArray(objects: helpImg!, sel_helpImg!, "Translation"), forKeys: ["norm_img","sel_img","caption"])
        var emailImg = UIImage(named: "email.png")
        var sel_emailImg = UIImage(named: "email_sel.png")
        var emailDict = NSDictionary(objects: NSArray(objects: emailImg!, sel_emailImg!, "Email"), forKeys: ["norm_img","sel_img","caption"])
        var camImg = UIImage(named: "cam.png")
        var sel_camImg = UIImage(named: "cam_sel.png")
        var camDict = NSDictionary(objects: NSArray(objects: camImg!, sel_camImg!, "Camera"), forKeys: ["norm_img","sel_img","caption"])
        var settings = UIImage(named: "settings.png")
        var sel_settingsImg = UIImage(named: "settings_sel.png")
        var settingsDict = NSDictionary(objects: NSArray(objects: settings!, sel_settingsImg!, "Settings"), forKeys: ["norm_img","sel_img","caption"])
        
        // Dialog box
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(4, target: self, selector: "showTestPromptWindow", userInfo: nil, repeats: false)
        
        cursor = Cursor()
        cursor.clipsToBounds = false
        cursor.delegate = self
        selRect = UIView(frame: CGRectMake(0, 0, 0, 0))
        selRect.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.35)
        selRect.layer.borderColor = UIColor.whiteColor().CGColor
        selRect.layer.borderWidth = 1
        selRect.clipsToBounds = false
        
        mainMenuArray = [helpDict, emailDict, camDict, settingsDict]
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        let devices = AVCaptureDevice.devices()
        for device in devices {
            if (device.hasMediaType(AVMediaTypeVideo)) {
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                    beginSession()
                }
            }
        }
    }
    func beginSession(){
        println("Beginning session")
        var error : NSError? = nil
        captureSession.addInput(AVCaptureDeviceInput(device: captureDevice!, error: &error))
        if error != nil{
            println("error: \(error?.localizedDescription)")
        }
        var previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        var connection = previewLayer.connection
        connection.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
        previewLayer?.frame = view.layer.frame
        view.layer.addSublayer(previewLayer)
        captureSession.startRunning()
        
        mainMenu = Menu(dimension: self.view.frame, numOfItems: 4, arrayDicts: mainMenuArray)
        view.addSubview(mainMenu)
        view.addSubview(cursor)
        view.addSubview(selRect)
        
        
        var longPressGesture = UILongPressGestureRecognizer(target: self, action: "showCursor")
        longPressGesture.minimumPressDuration = 1
        view.addGestureRecognizer(longPressGesture)
        
    }
    
    func showCursor(){
        if !cursorIsVisible{
            println("showing cursor")
            cursor.show()
            cursorIsVisible = true
            var panGesture = UIPanGestureRecognizer(target: self, action: "drag:")
            panGesture.maximumNumberOfTouches = 1
            panGesture.minimumNumberOfTouches = 1
            view.addGestureRecognizer(panGesture)
            activeUIElements.updateValue(cursor, forKey: "cursor")
        }
    }
    
    func drag(sender: UIPanGestureRecognizer){
        view.bringSubviewToFront(sender.view!)
        var translationPoint = sender.translationInView(view)
        if sender.state == UIGestureRecognizerState.Began{
            startingPoint = cursor.frame.origin
            cursor.startDragging(startingPoint)
            activeUIElements.updateValue(selRect, forKey: "selRect")
        }
        //check if current point is still in bounds
        if (cursor.frame.origin.x + 6 >= 0 && cursor.frame.origin.x + 6 <= view.frame.width) && (cursor.frame.origin.y + 6 >= 0 && cursor.frame.origin.y + 6 <= view.frame.height){
            cursor.moveWithTranslationPoint(translationPoint)
        }
        else{
            // Adjustments..
            var x: CGFloat = 0, y: CGFloat = 0
            if cursor.frame.origin.x < -6{
                x = -5
            }
            else if cursor.frame.origin.x + 6 > view.frame.width{
                x = view.frame.width - 7
            }
            if cursor.frame.origin.y < -6{
                y = -5
            }
            else if cursor.frame.origin.y + 6 > view.frame.height{
                y = view.frame.height - 7
            }
            cursor.frame.origin = CGPointMake(x, y)
        }
        
        
        if sender.state == UIGestureRecognizerState.Ended || sender.state == UIGestureRecognizerState.Cancelled{
            cursor.endDragging()
        }
    }
    
    func finishedSelection(){
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.selRect.alpha = 0
            }) { (complete) -> Void in
                self.selRect.frame = CGRectMake(0, 0, 0, 0)
                self.activeUIElements.removeValueForKey("selRect")
        }
    }
    
    func moveSelRectToPoint(point:CGPoint){
        selRect.frame.size = CGSizeMake(abs(point.x - startingPoint.x), abs(point.y - startingPoint.y))
        if point.x < startingPoint.x && point.y < startingPoint.y{
            selRect.frame.origin = CGPointMake(cursor.frame.origin.x + 6, cursor.frame.origin.y + 6)
        }
        else if point.x < startingPoint.x && point.y >= startingPoint.y{
            selRect.frame.origin = CGPointMake(cursor.frame.origin.x + 6, cursor.frame.origin.y - selRect.frame.size.height + 6)
        }
        else if point.x >= startingPoint.x && point.y < startingPoint.y{
            selRect.frame.origin = CGPointMake(cursor.frame.origin.x - selRect.frame.size.width + 6, cursor.frame.origin.y + 6)
        }
    }
    
    func positionSelRectAtPoint(point: CGPoint){
        selRect.frame.origin = point
        selRect.alpha = 1
    }
    
    func focus(){
        
    }
    
    func takePic(){
        
    }
    func showTestPromptWindow(){
        var strings = ["Yes","No","Cancel"]
        var promptBox = PromptBox(screenSize: CGSizeMake(view.frame.width, view.frame.height), title: "Notice", msg: "This is a test message", buttons: strings)
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.disablePageAndShowDialog(promptBox)
    }
}
