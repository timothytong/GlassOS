//
//  PromptBox.swift
//  GlassOS
//
//  Created by Timothy Tong on 2014-12-30.
//  Copyright (c) 2014 Timothy Tong. All rights reserved.
//

import UIKit
@objc protocol PromptBoxDelegate{
    func PromptBoxButtonClicked(button:String)
}
class PromptBox: UIView {
    private var numButtons = 0
//    private var buttons: Array<UIView>?
    private var buttonLabels: Array<UILabel>?
    var curActiveOpt = 0
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    init(frame: CGRect, title: String, msg: String, buttons: Array<String>?){
        super.init(frame: frame)
        if let btnAry = buttons{
            numButtons = btnAry.count
        }

        if numButtons > 3{
            numButtons = 3 // 3 buttons max...
        }
        
        backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        var buttonsArea = UIView(frame: CGRectMake(0, frame.height - 40, frame.width, 40))
        buttonsArea.layer.borderColor = UIColor.blackColor().CGColor
        buttonsArea.layer.borderWidth = 0.5
        if numButtons > 0{
            var singleWidth = frame.width / CGFloat(numButtons)
//            self.buttons = Array<UIView>()
            buttonLabels = Array<UILabel>()
            
            //Generate the buttons
            for i in 0 ..< numButtons{
                var btn = UIView(frame: CGRectMake(CGFloat(i)*singleWidth, 0, singleWidth, 50))
                btn.layer.borderWidth = 0.5
                btn.layer.borderColor = UIColor.blackColor().CGColor
                btn.backgroundColor = UIColor.whiteColor()
                var lbl = UILabel(frame: CGRectMake(0, 0, singleWidth, 50))
                lbl.text = buttons![i] as String
                lbl.font = UIFont(name: "HelveticaNeue-Thin", size: 18)
//                self.buttons!.append(btn)
                buttonLabels?.append(lbl)
            }
            
            
        }
        
    }
    func nextOption(){
        if curActiveOpt < numButtons - 1{
            unhighlight(curActiveOpt)
            highlight(++curActiveOpt)
        }
    }
    func prevOption(){
        if curActiveOpt > 0{
            unhighlight(curActiveOpt)
            highlight(--curActiveOpt)
        }
    }
    func highlight(slotNum: Int){
        if let btnLblAry = buttonLabels{
            var label = btnLblAry[slotNum] as UILabel
            label.backgroundColor = UIColor.blackColor()
            label.textColor = UIColor.whiteColor()
        }
    }
    func unhighlight(slotNum: Int){
        if let btnLblAry = buttonLabels{
            var label = btnLblAry[slotNum] as UILabel
            label.backgroundColor = UIColor.whiteColor()
            label.textColor = UIColor.blackColor()
        }
    }
}
