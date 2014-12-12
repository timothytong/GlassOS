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
    
    override func viewDidLoad() {
        println("CamView did load")
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.captureSession = AVCaptureSession()
        self.captureSession.sessionPreset = AVCaptureSessionPresetHigh
        let devices = AVCaptureDevice.devices()
        for device in devices {
            if (device.hasMediaType(AVMediaTypeVideo)) {
                if(device.position == AVCaptureDevicePosition.Back) {
                    self.captureDevice = device as? AVCaptureDevice
                    beginSession()
                }
            }
        }
    }
    func beginSession(){
        println("Beginning session")
        var error : NSError? = nil
        self.captureSession.addInput(AVCaptureDeviceInput(device: self.captureDevice!, error: &error))
        if error != nil{
            println("error: \(error?.localizedDescription)")
        }
        var previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        var connection = previewLayer.connection
        connection.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
        previewLayer?.frame = self.view.layer.frame
        self.view.layer.addSublayer(previewLayer)
        self.captureSession.startRunning()
    }
    
    
}
