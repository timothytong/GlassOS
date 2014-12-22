//
//  CamHomeController.swift
//  GlassOS
//
//  Created by Timothy Tong on 2014-12-11.
//  Copyright (c) 2014 Timothy Tong. All rights reserved.
//

import UIKit
import AVFoundation

class CamHomeController: UIViewController {
    var captureSession:AVCaptureSession!
    var captureDevice:AVCaptureDevice?
    var notificationBox: NotificationBox!
    var mainMenu: Menu!
    var mainMenuArray: Array<NSDictionary>!
    override func viewDidLoad() {
        super.viewDidLoad()
        println("CamView did load")
        view.backgroundColor = UIColor.whiteColor()
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
        notificationBox = NotificationBox(frame: CGRectMake(view.frame.width - 110, 10, 100, 60))
        
        
        mainMenu = Menu(dimension: self.view.frame, numOfItems: 4, arrayDicts: mainMenuArray)
        view.addSubview(mainMenu)
    }
    
    
}
