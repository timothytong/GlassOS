//
//  CamHomeController.swift
//  GlassOS
//
//  Created by Timothy Tong on 2014-12-11.
//  Copyright (c) 2014 Timothy Tong. All rights reserved.
//

import UIKit
import AVFoundation
import GPUImage

class CamHomeController: UIViewController, CursorDelegate, PromptBoxDelegate {
    private var captureSession:AVCaptureSession!
    private var captureDevice:AVCaptureDevice?
    private var mainMenu: Menu!
    private var mainMenuArray: Array<NSDictionary>!
    private var cursor: Cursor!
    private var cursorIsVisible = false
    private var canTapSelRect = false
    private var selRect: UIView!
    private var startingPoint = CGPointMake(0, 0)
    private var activeUIElements = Dictionary<String, UIView>()
    private var previewLayer:AVCaptureVideoPreviewLayer?
    private var imageOutput:AVCaptureStillImageOutput?
    private var sessionQueue:dispatch_queue_t!
    
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    let screenHeight = UIScreen.mainScreen().bounds.size.height
    override func viewDidLoad() {
        super.viewDidLoad()
        println("CamView did load")
        view.backgroundColor = UIColor.whiteColor()
        var sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL)
        self.sessionQueue = sessionQueue
        dispatch_async(sessionQueue, { () -> Void in
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
            self.mainMenuArray = [helpDict, emailDict, camDict, settingsDict]
            // Dialog box
            
            //        var timer = NSTimer.scheduledTimerWithTimeInterval(4, target: self, selector: "showTestPromptWindow", userInfo: nil, repeats: false)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.cursor = Cursor()
                self.cursor.clipsToBounds = false
                self.cursor.delegate = self
                self.selRect = UIView(frame: CGRectMake(0, 0, 0, 0))
                self.selRect.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.35)
                self.selRect.layer.borderColor = UIColor.whiteColor().CGColor
                self.selRect.layer.borderWidth = 1
                self.selRect.clipsToBounds = false
            })
            
            
            self.captureSession = AVCaptureSession()
            self.captureSession.sessionPreset = AVCaptureSessionPresetHigh
            let devices = AVCaptureDevice.devices()
            for device in devices {
                if (device.hasMediaType(AVMediaTypeVideo)) {
                    if(device.position == AVCaptureDevicePosition.Back) {
                        self.captureDevice = device as? AVCaptureDevice
                        self.beginSession()
                    }
                }
            }
            
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        dispatch_async(sessionQueue, { () -> Void in
            self.captureSession.stopRunning()
        })
    }
    
    func showCursor(){
        if !cursorIsVisible{
            println("showing cursor")
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.cursor.show()
                var panGesture = UIPanGestureRecognizer(target: self, action: "drag:")
                panGesture.maximumNumberOfTouches = 1
                self.view.addGestureRecognizer(panGesture)
                
            })
            activeUIElements.updateValue(cursor, forKey: "cursor")
            cursorIsVisible = true
        }
        
    }
    
    func drag(sender: UIPanGestureRecognizer){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.view.bringSubviewToFront(sender.view!)
            var translationPoint = sender.translationInView(self.view)
            if sender.state == UIGestureRecognizerState.Began{
                self.startingPoint = self.cursor.frame.origin
                self.cursor.startDragging(self.startingPoint)
                self.activeUIElements.updateValue(self.selRect, forKey: "selRect")
            }
            //check if current point is still in bounds
            if (self.cursor.frame.origin.x + 6 >= 0 && self.cursor.frame.origin.x + 6 <= self.view.frame.width) && (self.cursor.frame.origin.y + 6 >= 0 && self.cursor.frame.origin.y + 6 <= self.view.frame.height){
                self.cursor.moveWithTranslationPoint(translationPoint)
            }
            else{
                // Adjustments..
                var x: CGFloat = 0, y: CGFloat = 0
                if self.cursor.frame.origin.x < -6{
                    x = -5
                }
                else if self.cursor.frame.origin.x + 6 > self.view.frame.width{
                    x = self.view.frame.width - 7
                }
                if self.cursor.frame.origin.y < -6{
                    y = -5
                }
                else if self.cursor.frame.origin.y + 6 > self.view.frame.height{
                    y = self.view.frame.height - 7
                }
                self.cursor.frame.origin = CGPointMake(x, y)
            }
//            if sender.state == UIGestureRecognizerState.Ended{
//                
//            }
            if sender.state == UIGestureRecognizerState.Cancelled{
                self.cursor.endDragging()
            }
        })
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
    
    
    
    func PromptBoxButtonClicked(button: String) {
        if button == "Yes"{
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            appDelegate.dismissActivePromptWindow()
        }
    }
    
    
    
    
    // MARK: Camera
    func beginSession(){
        println("Beginning session")
        dispatch_async(sessionQueue, { () -> Void in
            var error : NSError? = nil
            self.captureSession.beginConfiguration()
            
            self.captureSession.addInput(AVCaptureDeviceInput(device: self.captureDevice!, error: &error))
            if error != nil{
                println("error: \(error?.localizedDescription)")
            }
            self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            var connection = self.previewLayer!.connection
            connection.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
            self.previewLayer?.frame = self.view.layer.frame
            self.view.layer.addSublayer(self.previewLayer!)
            
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.mainMenu = Menu(dimension: self.view.frame, numOfItems: 4, arrayDicts: self.mainMenuArray)
                self.view.addSubview(self.mainMenu)
                self.view.addSubview(self.cursor)
                self.view.addSubview(self.selRect)
                var longPressGesture = UILongPressGestureRecognizer(target: self, action: "showCursor")
                longPressGesture.minimumPressDuration = 1
                self.view.addGestureRecognizer(longPressGesture)
            })
            
            var imgOutput = AVCaptureStillImageOutput()
            if self.captureSession.canAddOutput(imgOutput){
                imgOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
                self.captureSession.addOutput(imgOutput)
                self.imageOutput = imgOutput
            }
            self.captureSession.commitConfiguration()
            self.captureSession.startRunning()
        })
    }
    
    func capture(){
        dispatch_async(self.sessionQueue, { () -> Void in
            // Update orientation on the image output connection before capturing
            self.imageOutput!.connectionWithMediaType(AVMediaTypeVideo).videoOrientation = self.previewLayer!.connection.videoOrientation
            if let device = self.captureDevice{
                //                if device.exposureMode == .Custom{
                //                    CamHomeController.setFlashMode(.Off, forDevice: device)
                //                }
                
                // Capture image.
                self.imageOutput!.captureStillImageAsynchronouslyFromConnection(self.imageOutput!.connectionWithMediaType(AVMediaTypeVideo), completionHandler: { (imageDataSampleBuffer, error) -> Void in
                    if ((imageDataSampleBuffer) != nil){
                        var imageData:NSData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                        var image = UIImage(data: imageData)
                        
                    }
                })
            }
        })
    }
    
    //    class func setFlashMode(flashMode: AVCaptureFlashMode, forDevice device:AVCaptureDevice){
    //
    //    }
    
    // Uses the origin of the cursor to determine where to focus to. ** Might not need this since we have autofocus.
    func cursorFocus(){
        if let device = captureDevice{
            if device.focusMode != .Locked && device.exposureMode != .Custom{
                var devicePoint:CGPoint = previewLayer!.captureDevicePointOfInterestForPoint(CGPointMake(cursor.frame.origin.x + 6, cursor.frame.origin.y))
                focusWithMode(.ContinuousAutoFocus, exposeWithMode: .ContinuousAutoExposure, atDevicePoint: devicePoint, monitorSubjectAreaChange: true)
            }
        }
    }
    
    
    func focusWithMode(focusMode:AVCaptureFocusMode, exposeWithMode exposureMode:AVCaptureExposureMode, atDevicePoint point:(CGPoint),monitorSubjectAreaChange enable:Bool){
        println("Focusing")
        if let device = captureDevice{
            var error:NSError?
            if device.lockForConfiguration(&error){
                if device.focusPointOfInterestSupported && device.isFocusModeSupported(focusMode){
                    device.focusMode = focusMode
                    device.focusPointOfInterest = point
                }
                if device.exposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode){
                    device.exposureMode = exposureMode
                    device.exposurePointOfInterest = point
                }
                device.subjectAreaChangeMonitoringEnabled = enable
                device.unlockForConfiguration()
            }
            else{
                println("\(error)")
            }
        }
        
    }
    
    // MARK: Functionality tests
    func showTestPromptWindow(){
        //        var strings = ["Yes","No","Cancel"]
        //        var promptBox = PromptBox(screenSize: CGSizeMake(view.frame.width, view.frame.height), title: "Notice", msg: "This is a test message", buttons: strings)
        //        promptBox.delegate = self
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.disablePageAndDisplayNotice("Notice", msg: "Some random error")
        appDelegate.disablePageAndDisplayNotice("Notice2", msg: "Some random error 2")
        appDelegate.disablePageAndDisplayNotice("Notice3", msg: "Some random error 3")
        //        appDelegate.disablePageAndShowDialog(promptBox)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /*
        var touch = touches.anyObject() as UITouch
        if let device = captureDevice{
        println("Focusing to point...")
        var point = touch.locationInView(self.view)
        focusWithMode(.ContinuousAutoFocus, exposeWithMode: .ContinuousAutoExposure, atDevicePoint: point, monitorSubjectAreaChange: true)
        }
        */
    }
}
