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

enum CamHomeFunctionMode{
    case DictionaryMode
    case CameraMode
}

class CamHomeController: UIViewController, CursorDelegate, OCRManagerDelegate{
    // Cursor & selection box
    var cursor: Cursor!
    var cursorIsVisible = false
    var canTapSelRect = false
    var selRect: UIView!
    var startingPoint = CGPointMake(0, 0)
    
    // Auxiliary
    var activeUIElements = Dictionary<String, UIView>()
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    // Camera
    var imageOutput: AVCaptureStillImageOutput?
    var sessionQueue: dispatch_queue_t!
    
    // Menu
    var mainMenu: Menu!
    var mainMenuArray: Array<NSDictionary>!
    
    // Camera
    var captureSession:AVCaptureSession!,
    captureDevice:AVCaptureDevice?,
    zoomOffsetX: CGFloat = 0,
    zoomOffsetY: CGFloat = 0,
    zoomScale = 1
    
    // OCR
    var ocrLanguage = "chi_sim"
    var ocrManager: OCRManager?
    var ocrImgView: UIImageView?
    var ocrResultWindow: UIView!
    
    var delegate: CamHomeControllerDelegate?
    let screenSize = Constants.screenSize()
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
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.selRect.alpha = 0
                }) { (complete) -> Void in
                    self.selRect.frame = CGRectMake(0, 0, 0, 0)
                    self.activeUIElements.removeValueForKey("selRect")
            }
        })
        
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
            self.switchToMode(CamHomeFunctionMode.DictionaryMode)
            //        NSThread.sleepForTimeInterval(2)
            
            //            dispatch_async(dispatch_get_main_queue(), { () -> Void in
            //                self.zoomInAtPoint(CGPointMake(0.7, 0.25), andScale: 1.3)
            //          })
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
                    var status = StatusCenter.sharedInstance
                    if ((imageDataSampleBuffer) != nil){
                        status.displayStatus("Captured.")
                        var imageData:NSData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                        var image = UIImage(data: imageData)
                        completion(image)
                    }
                    else{
                        status.displayStatus("Error capturing.")
                    }
                })
            }
        })
    }
    
    func captureSelectionAreaAndTranslate(){
        capture { (capturedImg) -> Void in
            println("==== Preparing to recognize.")
            dispatch_async(self.sessionQueue, { () -> Void in
                autoreleasepool { () -> () in
                    // Tesseract OCR
                    var status = StatusCenter.sharedInstance
                    status.displayStatus("Analyzing.")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.cursor.endDragging()
                        var image:UIImage = capturedImg!
                        var gpuImg = GPUImagePicture(image: image)
                        var cropRect = CGRectMake(self.selRect.frame.origin.x/self.screenSize.width, self.selRect.frame.origin.y/self.screenSize.height, self.selRect.frame.width/self.screenSize.width, self.selRect.frame.height/self.screenSize.height)
                        var cropFilter = GPUImageCropFilter(cropRegion: cropRect)
                        var croppedImg = cropFilter.imageByFilteringImage(image)
                        
                        if let imageView = self.ocrImgView{}
                        else{
                            self.ocrImgView = UIImageView(frame: self.selRect.frame)
                            self.ocrImgView!.image = croppedImg
                            self.ocrImgView!.alpha = 0
                            self.view.addSubview(self.ocrImgView!)
                        }
                        UIView.animateWithDuration(0.25, delay: 0, options: .CurveEaseIn, animations: { () -> Void in
                            self.ocrImgView!.alpha = 0.9
                            }, completion: { (complete) -> Void in
                                var grayScaleFilter = GPUImageGrayscaleFilter()
                                var bw_img = grayScaleFilter.imageByFilteringImage(croppedImg)
                                if let ocrmanager = self.ocrManager{
                                    ocrmanager.recognizeWithImage(bw_img.blackAndWhite())
                                }
                                else{
                                    println("OCRManager DNE!!!")
                                    status.displayStatus("Error.")
                                }
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    UIView.animateWithDuration(0.25, delay: 1, options: .CurveEaseIn, animations: { () -> Void in
                                        self.ocrImgView!.alpha = 0
                                        }, completion: { (complete) -> Void in
                                            self.ocrImgView!.image = bw_img
                                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                                UIView.animateWithDuration(0.25, delay: 0, options: .CurveEaseIn, animations: { () -> Void in
                                                    self.ocrImgView!.alpha = 0.7
                                                    }, completion: { (complete) -> Void in
                                                        UIView.animateWithDuration(0.35, delay: 1, options: .CurveEaseIn, animations: { () -> Void in
                                                            self.ocrImgView!.alpha = 0
                                                            }, completion: { (complete) -> Void in
                                                                self.ocrImgView!.image = nil
                                                                UIView.animateWithDuration(0.35, delay: 0, options: .CurveEaseIn, animations: { () -> Void in
                                                                    self.ocrResultWindow.alpha = 0.7
                                                                    }, completion: { (complete) -> Void in
                                                                        
                                                                })
                                                        })
                                                        
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
                var devicePoint:CGPoint = previewLayer!.captureDevicePointOfInterestForPoint(CGPointMake(cursor.frame.origin.x + 6 / self.screenSize.width, cursor.frame.origin.y / self.screenSize.height))
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
        //        var touch = touches.anyObject() as UITouch
        //        if let device = captureDevice{
        //        println("Focusing to point...")
        //        var point = touch.locationInView(self.view)
        //        var newPoint = CGPointMake(point.x / Constants.screenSize().width, point.y / Constants.screenSize().height)
        //        focusWithMode(.ContinuousAutoFocus, exposeWithMode: .ContinuousAutoExposure, atDevicePoint: newPoint, monitorSubjectAreaChange: true)
        //        }
    }
    
    func zoomInAtPoint(point:CGPoint!, andScale scale:CGFloat){
        if let pLayer = self.previewLayer{
            pLayer.anchorPoint = point
            UIView.animateWithDuration(1, animations: { () -> Void in
                pLayer.transform = CATransform3DMakeScale(scale, scale, 0)
                }, completion: { (complete) -> Void in
                    pLayer.frame.origin.x = (pLayer.frame.origin.x > 0) ? 0 : ((pLayer.frame.origin.x + pLayer.frame.width < self.view.bounds.width) ? self.view.bounds.width - pLayer.frame.width : pLayer.frame.origin.x)
                    pLayer.frame.origin.y = (pLayer.frame.origin.y > 0) ? 0 : ((pLayer.frame.origin.y + pLayer.frame.width < self.view.bounds.height) ? self.view.bounds.height - pLayer.frame.height : pLayer.frame.origin.y)
                    self.zoomOffsetX = -pLayer.frame.origin.x
                    self.zoomOffsetY = -pLayer.frame.origin.y
                    println("after: \(pLayer.frame.origin.x), \(pLayer.frame.origin.y), \(pLayer.frame.width), \(pLayer.frame.height)")
            })
        }
    }
    //pragma MARK: Modes
    func switchToMode(mode:CamHomeFunctionMode){
        switch mode{
        case CamHomeFunctionMode.DictionaryMode:
            if (ocrManager == nil){
                println("Creating OCRManager.")
                ocrManager = OCRManager(language: ocrLanguage)
                ocrManager!.delegate = self
            }
        default:
            if (ocrManager != nil){
                ocrManager = nil
            }
            break
        }
    }
    //pragma MARK: OCRManager
    func recognitionComplete(recognizedText: String?) {
        var status = StatusCenter.sharedInstance
        if let text = recognizedText{
            if text != ""{
                println("RECOGNIZED: \(text)")
                status.displayStatus("Translating.")
                var translator = FGTranslator(bingAzureClientId: "timothytong001", secret: "ykVQA7+f2GNEG6ihLEK+OwYrXmfo3fkIy+wq17aYwyE=")
                translator.translateText(text, completion: { (err, translated, sourceLang) -> Void in
                    autoreleasepool({ () -> () in
                        println("Translation complete: \(text) -> \(translated)")
                        translator = nil
                        status.displayStatus("Done.")
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            var recLabelText = text as NSString
                            var recTextRectSize = recLabelText.boundingRectWithSize(CGSizeMake(self.view.frame.width - 10, 40), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Thin", size: 24)!], context: nil).size
                            var transTextRectSize = translated.boundingRectWithSize(CGSizeMake(self.view.frame.width - 10, 40), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Thin", size: 24)!], context: nil).size
                            var finalRectSize = (recTextRectSize.width >= transTextRectSize.width) ? recTextRectSize : transTextRectSize
                            if (self.ocrResultWindow != nil){
                                println(" -- Removing existing OCR window from superview")
                                self.ocrResultWindow.removeFromSuperview()
                                self.ocrResultWindow = nil
                            }
                            if let ocrImgView = self.ocrImgView{
                                self.ocrResultWindow = UIView(frame:CGRectMake(ocrImgView.frame.origin.x, ocrImgView.frame.origin.y, finalRectSize.width + 10, finalRectSize.height + 10))
                                self.ocrResultWindow.backgroundColor = UIColor.whiteColor()
                                self.ocrResultWindow.alpha = 0
                                self.ocrResultWindow.clipsToBounds = true
                                
                                // dynamic label size
                                // code to generate a bounding rect for text at various font sizes
                                var txtLabel = UILabel(frame: CGRectMake(5, 5, finalRectSize.width, finalRectSize.height))
                                txtLabel.text = text
                                txtLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 24)
                                txtLabel.textAlignment = .Center
                                self.ocrResultWindow.addSubview(txtLabel)
                                self.view.addSubview(self.ocrResultWindow)
                                
                                UIView.animateWithDuration(1, delay: 3.7, options: .CurveEaseInOut, animations: { () -> Void in
                                    self.ocrResultWindow.transform = CGAffineTransformMakeTranslation(self.screenSize.width - 5 - self.ocrResultWindow.frame.width - self.ocrResultWindow.frame.origin.x, 5 - self.ocrResultWindow.frame.origin.y)
                                    }, completion: { (complete) -> Void in
                                        var translationLbl = UILabel(frame: CGRectMake(5, finalRectSize.height + 5, finalRectSize.width, finalRectSize.height))
                                        translationLbl.text = translated
                                        translationLbl.textAlignment = .Center
                                        translationLbl.font = UIFont(name: "HelveticaNeue-Thin", size: 24)
                                        self.ocrResultWindow.addSubview(translationLbl)
                                        UIView.animateWithDuration(0.6, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                                            self.ocrResultWindow.frame = CGRectMake(self.ocrResultWindow.frame.origin.x, self.ocrResultWindow.frame.origin.y, self.ocrResultWindow.frame.width, 2 * self.ocrResultWindow.frame.height - 10)
                                            }, completion: { (complete) -> Void in
                                                
                                        })
                                })
                            }
                        })
                    })
                })
            }else{
                UIView.animateWithDuration(0.3, delay: 1, options: .CurveEaseInOut, animations: { () -> Void in
                    self.ocrResultWindow.alpha = 0
                    }, completion: { (complete) -> Void in
                        status.displayStatus("Error translating.")
                })
            }
        }
        else{
            UIView.animateWithDuration(0.3, delay: 1, options: .CurveEaseInOut, animations: { () -> Void in
                self.ocrResultWindow.alpha = 0
                }, completion: { (complete) -> Void in
                    status.displayStatus("Error recognizing.")
            })
        }
    }
}
