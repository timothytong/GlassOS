//
//  Menu.swift
//  GlassOS
//
//  Created by Timothy Tong on 2014-12-19.
//  Copyright (c) 2014 Timothy Tong. All rights reserved.
//

import UIKit
// TODO: when hiding menu, check which mode is ACTIVE(enabled) then disable.
class Menu: UIView, MenuBlockDelegate {
    var numItems:Int!
    var background:UIView!
    var slots:Array<UIView>!
    private var activ_slot:MenuBlock?
    private let singleHeight:CGFloat = 44
    private var block_is_animating = false
    init(dimension: CGRect , numOfItems: Int, arrayDicts: Array<NSDictionary>!){
        /*
        arrayDicts consists of following elements: norm_img, sel_img, func_name
        */
        let height = 46 * CGFloat(numOfItems) + 2
        super.init(frame: CGRectMake(dimension.width - 60, dimension.height - height - 10, 50, height))
        
        var tabs = Array<UIView>()
        numItems = numOfItems
        slots = Array<UIView>()
        background = UIView(frame: CGRectMake(0, 50, frame.width, frame.height))
        background.backgroundColor = UIColor.clearColor()
        alpha = 0
        backgroundColor = UIColor.clearColor()
        //Actual implementation
        if arrayDicts?.count < numOfItems{
            numItems = arrayDicts?.count
        }
        for i in 0..<numItems{
            var dict = arrayDicts![i] as NSDictionary
            var block = MenuBlock(frame: CGRectMake(3, 65 * CGFloat(i), singleHeight, singleHeight), img: dict.objectForKey("norm_img") as UIImage, hilight_img: dict.objectForKey("sel_img") as UIImage, func_name: dict.objectForKey("caption") as String)
            block.tag = i
            block.delegate = self
            var tap = UITapGestureRecognizer(target: self, action: "blockTapped:")
            var doubleTap = UITapGestureRecognizer(target: self, action: "blockDoubleTapped:")
            doubleTap.numberOfTapsRequired = 2
            tap.requireGestureRecognizerToFail(doubleTap)
            block.addGestureRecognizer(tap)
            block.addGestureRecognizer(doubleTap)
            block.alpha = 0
            block.clipsToBounds = false
            background.addSubview(block)
            slots.append(block)
        }
        addSubview(background)
        var timer = NSTimer.scheduledTimerWithTimeInterval(4, target: self, selector: "showMenu", userInfo: nil, repeats: false)
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func showMenu(){
        //        println("Showing")
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.alpha = 1
            self.background.frame = CGRectMake(0, 0, self.background.frame.width, self.background.frame.height)
            }) { (complete) -> Void in
                var block = self.slots[0] as MenuBlock
                block.highlight()
                self.activ_slot = block
                var timer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: "hideMenu", userInfo: nil, repeats: false)
        }
        for i in 0..<self.numItems{
            self.showOptionNum(i)
        }
        var block = self.slots[0] as MenuBlock
        block.enable()
    }
    func showOptionNum(input:Int){
        //        println("showing \(input)")
        var i = Double(input)
        var time = 0.3 + 0.1*i
        UIView.animateWithDuration(time, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            var block = self.slots[input]
            block.frame = CGRectMake(3,CGFloat(2+2*i+i*44) , self.singleHeight, self.singleHeight)
            block.alpha = 1
            }) { (complete) -> Void in
        }
    }
    func hideMenu(){
        for i in 0..<self.numItems{
            self.hideOptionNum(i)
        }
        UIView.animateWithDuration(0.3, delay: 0.5 + 0.1 * Double(self.numItems), options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.alpha = 0
            self.background.frame = CGRectMake(0, 50, self.background.frame.width, self.background.frame.height)
            }) { (complete) -> Void in
        }
    }
    func hideOptionNum(input:Int){
        //        println("hiding \(input)")
        var i = Double(input)
        var time = 0.2 + 0.1*i
        UIView.animateWithDuration(time, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            var block = self.slots[input]
            block.frame = CGRectMake(3,65 * CGFloat(i) , self.singleHeight, self.singleHeight)
            block.alpha = 0
            }) { (complete) -> Void in
        }
    }
    func blockTapped(sender:UITapGestureRecognizer){
        //        println("block tapped, sender tag: \(sender.view!.tag)")
        var targetBlock = slots[sender.view!.tag] as MenuBlock
        hilightSlot(targetBlock)
        block_is_animating = true
    }
    func blockDoubleTapped(sender:UITapGestureRecognizer){
        println("block double-tapped, sender tag: \(sender.view!.tag)")
        var targetBlock = slots[sender.view!.tag] as MenuBlock
        targetBlock.enable()
    }
    func hilightSlot(block: MenuBlock){
        if !block_is_animating{
            activ_slot?.unhighlight()
            activ_slot = block
            activ_slot!.highlight()
        }
    }
    func animationCompl(){
        if block_is_animating{
            block_is_animating = false
        }
    }
    
}
