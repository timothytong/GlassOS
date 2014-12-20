//
//  CamHomeController.swift
//  VROS
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
    override func viewDidLoad() {
        println("CamView did load")
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
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
        
    }
    
    
}
