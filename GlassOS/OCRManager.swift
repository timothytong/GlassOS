//
//  OCRManager.swift
//  GlassOS
//
//  Created by Timothy Tong on 2015-02-07.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

import UIKit
@objc protocol OCRManagerDelegate{
    func recognitionComplete(recognizedText:String?)
    func timeoutAndAbortOCR(abort:Bool)
}
class OCRManager:NSObject, TesseractDelegate{
    var tesseract:Tesseract!,
    delegate:AnyObject?,
    timer:NSTimer!,
    timeoutTimer:NSTimer!,
    numTimeouts = 0,
    tesseractLan = ""
    init(language:String!){
        super.init()
        println("OCRManager -- INIT")
        tesseractLan = language
    }
    func setLanguage(newLanguage:String!){
        println("OCRManager -- SET LANGUAGE")
        tesseract = nil
        tesseractLan = newLanguage
    }
    func recognizeWithImage(image:UIImage!){
        tesseract = Tesseract(language: tesseractLan)
        tesseract.image = image
        tesseract.recognize()
        println("creating timer...")
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "checkProgress", userInfo: nil, repeats: true)
        self.timeoutTimer = NSTimer.scheduledTimerWithTimeInterval(4, target: self, selector: "timeout", userInfo: nil, repeats: true)
        println("OCRManager -- RECOGNIZING")
    }
    func checkProgress(){
        println("Checking progress")
        if let tes = tesseract{
            println("////Tesseract still alive.")
            if tes.progress == 100{
                self.timeoutTimer.invalidate()
                println("////////Tesseract done recognizing.")
                self.timer.invalidate()
                if let text = tes.recognizedText{
                    self.delegate?.recognitionComplete(text)
                }
            }else{
                println("////////Tesseract progress:\(tes.progress)")
            }
        }else{
            println("\\\\\\\\Tesseract dead.")
            self.delegate?.recognitionComplete(nil)
        }
    }
    func progressImageRecognitionForTesseract(tesseract: Tesseract!) {
    }
    func shouldCancelImageRecognitionForTesseract(tesseract: Tesseract!) -> Bool {
        return false
    }
    func timeout(){
        if ++self.numTimeouts == 1{
            self.delegate?.timeoutAndAbortOCR(false)
        }else{
            self.timeoutTimer.invalidate()
            self.timer.invalidate()
            self.numTimeouts = 0
            self.delegate?.timeoutAndAbortOCR(true)
            self.tesseract = nil
        }
    }
}
