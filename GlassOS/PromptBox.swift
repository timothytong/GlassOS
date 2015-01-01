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
/*
In general - Create a prompbox object then send it to the app delegate.
Can't pass the button strings right into appDelegate because each button might have its unique
respond function when pressed.

To quickly generate error window: call disablePageAndDisplayNotice in AppDelegate.
*/

class PromptBox: UIView {
    private var numButtons = 0
    //    private var buttons: Array<UIView>?
    private var buttonLabels: Array<UILabel>?
    var curActiveOpt = 0
    var delegate: PromptBoxDelegate?
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    init(screenSize: CGSize, title: String!, msg: String!, buttons: Array<String>?){
        super.init(frame: CGRectMake(screenSize.width / 2 - 150, screenSize.height / 2 - 100, 300, 200))
        if let btnAry = buttons{
            numButtons = btnAry.count
        }
        if numButtons > 3{
            numButtons = 3 // 3 buttons max...
        }
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.blackColor().CGColor
        backgroundColor = UIColor.whiteColor()
        var buttonsArea = UIView(frame: CGRectMake(0, frame.height - 40, frame.width, 40))
        buttonsArea.layer.borderColor = UIColor.blackColor().CGColor
        buttonsArea.layer.borderWidth = 0.5
        var titleLabel = UILabel(frame: CGRectMake(0, 0, 300, 40))
        titleLabel.font = UIFont(name: "HelveticaNeue", size: 23)
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.text = title
        var sepLine = UIView(frame: CGRectMake(20, 40, 260, 1))
        sepLine.backgroundColor = UIColor.blackColor()
        var msgLabel = UILabel(frame: CGRectMake(20, 40, 260, 110))
        msgLabel.numberOfLines = 0
        msgLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        msgLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 19)
        msgLabel.text = msg
        
        addSubview(titleLabel)
        addSubview(msgLabel)
        addSubview(sepLine)

        if numButtons > 0{
            var singleWidth = frame.width / CGFloat(numButtons)
            //            self.buttons = Array<UIView>()
            buttonLabels = Array<UILabel>()
            
            //Generate the buttons
            for i in 0 ..< numButtons{
                var btn = UIView(frame: CGRectMake(CGFloat(i)*singleWidth, frame.height - 50, singleWidth, 50))
                btn.layer.borderWidth = 0.5
                btn.layer.borderColor = UIColor.blackColor().CGColor
                btn.backgroundColor = UIColor.whiteColor()
                btn.tag = i
                var btnTap = UITapGestureRecognizer(target: self, action: "buttonClicked:")
                btn.addGestureRecognizer(btnTap)
                var lbl = UILabel(frame: CGRectMake(0, 0, singleWidth, 50))
                lbl.text = buttons![i] as String
                lbl.font = UIFont(name: "HelveticaNeue-Thin", size: 18)
                lbl.textColor = UIColor.blackColor()
                lbl.textAlignment = NSTextAlignment.Center
                lbl.userInteractionEnabled = false
                //                self.buttons!.append(btn)
                buttonLabels?.append(lbl)
                btn.addSubview(lbl)
                addSubview(btn)
            }
        }

        if numButtons >= 1{
            highlightSlot(0)
        }
    }
    func buttonClicked(sender: UITapGestureRecognizer){
        println("button clicked")
        var num = sender.view!.tag
        self.delegate?.PromptBoxButtonClicked(buttonLabels![num].text!)
    }
    func nextOption(){
        if curActiveOpt < numButtons - 1{
            unhighlightSlot(curActiveOpt)
            highlightSlot(++curActiveOpt)
        }
    }
    func prevOption(){
        if curActiveOpt > 0{
            unhighlightSlot(curActiveOpt)
            highlightSlot(--curActiveOpt)
        }
    }
    func highlightSlot(slotNum: Int){
        if let btnLblAry = buttonLabels{
            var label = btnLblAry[slotNum] as UILabel
            label.backgroundColor = UIColor.blackColor()
            label.textColor = UIColor.whiteColor()
            label.layer.borderColor = UIColor.whiteColor().CGColor
            label.layer.borderWidth = 3
        }
    }
    func unhighlightSlot(slotNum: Int){
        if let btnLblAry = buttonLabels{
            var label = btnLblAry[slotNum] as UILabel
            label.backgroundColor = UIColor.whiteColor()
            label.textColor = UIColor.blackColor()
            label.layer.borderColor = UIColor.blackColor().CGColor
            label.layer.borderWidth = 0.5
        }
    }
}
