//
//  Menu.swift
//  GlassOS
//
//  Created by Timothy Tong on 2014-12-19.
//  Copyright (c) 2014 Timothy Tong. All rights reserved.
//

import UIKit

class Menu: UIView {
    var numItems:Int!
    var background:UIView!
    var slots:Array<UIView>!
    
    init(dimension: CGRect , numOfItems: Int, arrayDicts: Array<NSDictionary>?){
        let height = 46 * CGFloat(numOfItems) + 2
        super.init(frame: CGRectMake(dimension.width - 60, dimension.height - height - 10, 50, height))
        let singleHeight:CGFloat = 44
        var tabs = Array<UIView>()
        numItems = numOfItems
        slots = Array<UIView>()
        background = UIView(frame: CGRectMake(0, 50, frame.width, frame.height))
        background.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        alpha = 0
        
        backgroundColor = UIColor.clearColor()
        // Actual implementation
        //        if arrayDicts.count < numOfItems{
        //            numItems = arrayDicts.count
        //        }
        for i in 0..<numItems{
            var block = UIView(frame: CGRectMake(3, 48 * CGFloat(i), singleHeight, singleHeight))//0 -> block.height
            //            block.layer.borderColor = UIColor.blackColor().CGColor
            //            block.layer.borderWidth = 0.5
            var helpImg = UIImage(named: "help.png")
            var helpImgView = UIImageView(frame: CGRectMake(0, 0, singleHeight, singleHeight))
            helpImgView.image = helpImg
            block.clipsToBounds = true
            block.alpha = 0
            block.addSubview(helpImgView)
            background.addSubview(block)
            slots.append(block)
        }
        addSubview(background)
        var timer = NSTimer.scheduledTimerWithTimeInterval(4, target: self, selector: "showMenu", userInfo: nil, repeats: false)
        println("Counting")
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func showMenu(){
        println("Showing")
        UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.alpha = 1
            self.background.frame = CGRectMake(0, 0, self.background.frame.width, self.background.frame.height)
            for i in 0..<self.numItems{
                self.showOptionNum(i)
            }
            }) { (complete) -> Void in
                
        }
    }
    func showOptionNum(input:Int){
        println("showing \(input)")
        var i = input
        UIView.animateWithDuration(1, delay: (0.2 * Double(i)), options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            var block = self.slots[i]
            block.frame = CGRectMake(3,CGFloat(2+2*i+i*44) , 44, 44)
            block.alpha = 1
            }) { (complete) -> Void in
        }
    }
    func hideMenu(){
        
    }
    
}
