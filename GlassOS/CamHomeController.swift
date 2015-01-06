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

@objc protocol CamHomeControllerDelegate{
    func CameraSessionDidBegin()
    func setProgress(num: Float)
}

class CamHomeController: UIViewController, CursorDelegate, TesseractDelegate{
    private var captureSession:AVCaptureSession!
    private var captureDevice:AVCaptureDevice?
    
    private var cursor: Cursor!
    private var cursorIsVisible = false
    private var canTapSelRect = false
    private var selRect: UIView!
    private var startingPoint = CGPointMake(0, 0)
    private var activeUIElements = Dictionary<String, UIView>()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var imageOutput: AVCaptureStillImageOutput?
    private var sessionQueue: dispatch_queue_t!
    private var tesseract: Tesseract!
    private var ocrResultWindow: UIView!
    private var mainMenu: Menu!
    private var mainMenuArray: Array<NSDictionary>!
    private var translator: FGTranslator?
    var delegate: CamHomeControllerDelegate?
    
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    let screenHeight = UIScreen.mainScreen().bounds.size.height
    let screenSize = UIScreen.mainScreen().bounds.size
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate?.setProgress(0.2)
        println("CamView did load")
        view.backgroundColor = UIColor.whiteColor()
        var sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL)
        self.sessionQueue = sessionQueue
        dispatch_async(sessionQueue, { () -> Void in
            // Main Menu
            // Can add youtube, music, safari etc...
            var helpImg = UIImage(named: "help.png")
            var sel_helpImg = UIImage(named: "help_sel.png")
            var helpDict = NSDictionary(objects: NSArray(objects: helpImg!, sel_helpImg!, "Dictionary"), forKeys: ["norm_img","sel_img","caption"])
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
            
            
            // Tesseract OCR
            self.tesseract = Tesseract(language: "chi_sim")
            self.tesseract.delegate = self
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
                var selRectTap = UITapGestureRecognizer(target: self, action: "openSelRectPrompt")
                self.selRect.addGestureRecognizer(selRectTap)
                self.ocrResultWindow = UIView(frame: CGRectMake(0, 0, 0, 0))
            })
            
            self.captureSession = AVCaptureSession()
            self.captureSession.sessionPreset = AVCaptureSessionPresetHigh
            self.delegate?.setProgress(0.4)
            let devices = AVCaptureDevice.devices()
            for device in devices {
                if (device.hasMediaType(AVMediaTypeVideo)) {
                    if(device.position == AVCaptureDevicePosition.Back) {
                        self.captureDevice = device as? AVCaptureDevice
                        self.beginSession()
                        self.delegate?.setProgress(0.5)
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
    
    // MARK: Cursor
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
    
    // MARK: Selection Box
    func drag(sender: UIPanGestureRecognizer){
        //        dispatch_async(dispatch_get_main_queue(), { () -> Void in
        //            self.view.bringSubviewToFront(sender.view!)
        var translationPoint = sender.translationInView(self.view)
        if sender.state == .Began{
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
        //            if sender.state == .Changed{
        //
        //            }
        if sender.state == .Cancelled{
            println("sender state - cancelled")
            self.cursor.endDragging()
        }
        if sender.state == .Ended{
            println("ended")
            self.canTapSelRect = true
            println("canTapSelRect set to true")
        }
        //        })
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
    
    func openSelRectPrompt(){
        autoreleasepool({ () -> () in
            if self.canTapSelRect{
                println("selRect Tapped")
                self.canTapSelRect = false
                var translationPrompt = PromptBox(screenSize: self.screenSize, title: "Dictionary.", msg: "Try to recognize this selection?", buttons: ["Yes", "No"], name: "selrect")
                var appDel = UIApplication.sharedApplication().delegate as AppDelegate
                appDel.disablePageAndShowDialog(translationPrompt)
            }
        })
    }
    
    // MARK: Camera
    func beginSession(){
        println("Beginning session")
        dispatch_async(sessionQueue, { () -> Void in
            self.delegate?.setProgress(0.7)
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
            self.delegate?.setProgress(1)
            self.captureSession.commitConfiguration()
            self.captureSession.startRunning()
            self.delegate?.CameraSessionDidBegin()
            
        })
    }
    
    func capture(completion: (UIImage?)->Void){
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
                        completion(image)
                    }
                })
            }
        })
    }
    
    func captureSelectionArea(){
        capture { (capturedImg) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                autoreleasepool { () -> () in
                    self.cursor.endDragging()
                    var image:UIImage = capturedImg!
                    var gpuImg = GPUImagePicture(image: image)
                    //                    var cropPath = UIBezierPath(roundedRect: CGRectMake(0, 0, self.selRect.frame.width, self.selRect.frame.height), cornerRadius: 0)
                    //                    var mask = CAShapeLayer()
                    //                    mask.frame = CGRectMake(self.selRect.frame.origin.x, self.selRect.frame.origin.y
                    //                        , self.selRect.frame.width, self.selRect.frame.height)
                    //                    mask.path = cropPath.CGPath
                    //                    var imageView = UIImageView(frame: CGRectMake(0, 0, self.screenWidth, self.screenHeight))
                    //                    println("CropRect: (\(self.selRect.frame.origin.x),\(self.selRect.frame.origin.y),\(self.selRect.frame.width),\(self.selRect.frame.height))")
                    var cropRect = CGRectMake(self.selRect.frame.origin.x/self.screenWidth, self.selRect.frame.origin.y/self.screenHeight, self.selRect.frame.width/self.screenWidth, self.selRect.frame.height/self.screenHeight)
                    var cropFilter = GPUImageCropFilter(cropRegion: cropRect)
                    //                    gpuImg.addTarget(cropFilter)
                    //                    cropFilter.useNextFrameForImageCapture()
                    //                    gpuImg.processImage()
                    var croppedImg = cropFilter.imageByFilteringImage(image)
                    var imageView = UIImageView(frame: self.selRect.frame)
                    imageView.image = croppedImg
                    //                    imageView.layer.mask = mask
                    imageView.alpha = 0
                    self.view.addSubview(imageView)
                    UIView.animateWithDuration(0.25, delay: 0, options: .CurveEaseIn, animations: { () -> Void in
                        imageView.alpha = 0.7
                        }, completion: { (complete) -> Void in
                            var grayScaleFilter = GPUImageGrayscaleFilter()
                            var bw_img = grayScaleFilter.imageByFilteringImage(croppedImg)
                            dispatch_async(self.sessionQueue, { () -> Void in
                                println("Recognizing.")
                                self.tesseract.image = bw_img.blackAndWhite()
                                if self.tesseract.recognize(){
                                    var recText = self.tesseract.recognizedText
                                    self.translator = FGTranslator(bingAzureClientId: "timothytong001", secret: "ykVQA7+f2GNEG6ihLEK+OwYrXmfo3fkIy+wq17aYwyE=")
                                    self.translator!.translateText(recText, completion: { (err, translated, sourceLang) -> Void in
                                        
                                        var error = false
                                        if recText == ""{
                                            recText = "Error."
                                            error = true
                                        }
                                        println("RECOGNIZED: \(recText)")
                                        //                                    API.googleTranslate(recText)
                                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                            var height = imageView.frame.height
                                            var width = imageView.frame.width
                                            if height < 30{
                                                height = 30
                                            }
                                            if width < 60{
                                                width = 60
                                            }
                                            if (self.ocrResultWindow != nil){
                                                self.ocrResultWindow.removeFromSuperview()
                                                self.ocrResultWindow = nil
                                            }
                                            self.ocrResultWindow = UIView(frame:CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, width, height))
                                            self.ocrResultWindow.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8)
                                            self.ocrResultWindow.alpha = 0
                                            self.ocrResultWindow.clipsToBounds = true
                                            var txtLabel = UILabel(frame: CGRectMake(0, 0, width, height))
                                            txtLabel.text = recText
                                            var fontSize:CGFloat = 18 + height * 0.15
                                            txtLabel.font = UIFont(name: "HelveticaNeue-Thin", size: fontSize)
                                            if fontSize > 25{
                                                fontSize = 25
                                            }
                                            txtLabel.textAlignment = .Center
                                            self.ocrResultWindow.addSubview(txtLabel)
                                            self.view.addSubview(self.ocrResultWindow)
                                            if error{
                                                UIView.animateWithDuration(0.3, delay: 1, options: .CurveEaseInOut, animations: { () -> Void in
                                                    self.ocrResultWindow.alpha = 0
                                                    }, completion: { (complete) -> Void in
                                                })
                                            }
                                            else{
                                                UIView.animateWithDuration(1, delay: 3.7, options: .CurveEaseInOut, animations: { () -> Void in
                                                    self.ocrResultWindow.transform = CGAffineTransformMakeTranslation(self.screenWidth - 5 - self.ocrResultWindow.frame.width - self.ocrResultWindow.frame.origin.x, 5 - self.ocrResultWindow.frame.origin.y)
                                                    }, completion: { (complete) -> Void in
                                                        var translationLbl = UILabel(frame: CGRectMake(0, height, width, height))
                                                        translationLbl.text = translated
                                                        translationLbl.textAlignment = .Center
                                                        translationLbl.font = UIFont(name: "HelveticaNeue-Ultralight", size: fontSize)
                                                        self.ocrResultWindow.addSubview(translationLbl)
                                                        UIView.animateWithDuration(0.6, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                                                            self.ocrResultWindow.frame = CGRectMake(self.ocrResultWindow.frame.origin.x, self.ocrResultWindow.frame.origin.y, self.ocrResultWindow.frame.width, 2 * self.ocrResultWindow.frame.height)
                                                            }, completion: { (complete) -> Void in
                                                                
                                                        })
                                                })
                                            }
                                        })
                                        
                                    })
                                }else{
                                    println("Cannot recognize text.")
                                }
                            })
                            UIView.animateWithDuration(0.25, delay: 1, options: .CurveEaseIn, animations: { () -> Void in
                                imageView.alpha = 0
                                }, completion: { (complete) -> Void in
                                    imageView.removeFromSuperview()
                                    imageView.image = bw_img
                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                        imageView.alpha = 0
                                        self.view.addSubview(imageView)
                                        UIView.animateWithDuration(0.25, delay: 0, options: .CurveEaseIn, animations: { () -> Void in
                                            imageView.alpha = 0.7
                                            }, completion: { (complete) -> Void in
                                                UIView.animateWithDuration(0.35, delay: 1, options: .CurveEaseIn, animations: { () -> Void in
                                                    imageView.alpha = 0
                                                    }, completion: { (complete) -> Void in
                                                        UIView.animateWithDuration(0.35, delay: 0, options: .CurveEaseIn, animations: { () -> Void in
                                                            self.ocrResultWindow.alpha = 0.7
                                                            }, completion: { (complete) -> Void in
                                                                
                                                        })
                                                })
                                                
                                        })
                                    })
                                    
                            })
                    })
                    
                }
            })
        }
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
    
    func progressImageRecognitionForTesseract(tesseract:Tesseract) {
        println("progress: \(tesseract.progress)")
    }
    func shouldCancelImageRecognitionForTesseract(tesseract: Tesseract!) -> Bool {
        return false
    }
}
