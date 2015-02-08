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
}
class OCRManager:NSObject, TesseractDelegate{
    var tesseract:Tesseract!,
    delegate:AnyObject?,
    timer:NSTimer!
    init(language:String!){
        super.init()
        tesseract = Tesseract(language: language)
        println("OCRManager -- INIT")
    }
    func setLanguage(newLanguage:String!){
        println("OCRManager -- SET LANGUAGE")
        tesseract = nil
        tesseract = Tesseract(language: newLanguage)
    }
    func recognizeWithImage(image:UIImage!){
        tesseract.image = image
        tesseract.recognize()

            println("creating timer...")
            self.timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "checkProgress", userInfo: nil, repeats: true)

        
        println("OCRManager -- RECOGNIZING")
    }
    func checkProgress(){
        println("Checking progress")
        if let tes = tesseract{
            println("////Tesseract still alive.")
            if tes.progress == 100{
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
}
