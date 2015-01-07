//
//  MenuBlock.swift
//  GlassOS
//
//  Created by Timothy Tong on 2014-12-22.
//  Copyright (c) 2014 Timothy Tong. All rights reserved.
//

import UIKit
@objc protocol MenuBlockDelegate{
    func animationCompl()
}
class MenuBlock: UIView {
    var delegate: MenuBlockDelegate?
    var imgView: UIImageView!
    var sel_imgView: UIImageView!
    var caption: String!
    var label: UILabel!
    var labelBG: UIView!
    var isHilighted: Bool!
    var isEnabled: Bool!
    var backCircle: UIView!
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    init(frame: CGRect, img: UIImage!, hilight_img: UIImage!, func_name: String!){
        super.init(frame: frame)
        backCircle = UIView(frame: CGRectMake(0, 0, frame.width, frame.height))
        backCircle.userInteractionEnabled = false
        var path = UIBezierPath(roundedRect: CGRectMake(0, 0, frame.width, frame.height), cornerRadius: frame.width/2)
        var mask = CAShapeLayer()
        mask.path = path.CGPath
        backCircle.layer.mask = mask
        backCircle.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4)
        addSubview(backCircle)
        backCircle.alpha = 0
        isHilighted = false
        isEnabled = false
        var imgViewBG = UIView(frame: CGRectMake(0, 0, frame.width, frame.height))
        imgViewBG.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4)
        backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4)
        imgView = UIImageView(frame: CGRectMake(2, 2, frame.width-4, frame.height-4))
        imgView.image = img
        imgView.backgroundColor = UIColor.clearColor()
        imgViewBG.addSubview(imgView)
        addSubview(imgView)
        sel_imgView = UIImageView(frame: CGRectMake(2, 2, frame.width-4, frame.height-4))
        sel_imgView.image = hilight_img
        sel_imgView.backgroundColor = UIColor.clearColor()
        addSubview(sel_imgView)
        sel_imgView.alpha = 0
        caption = func_name
        labelBG = UIView(frame: CGRectMake(-105, 0, 100, frame.height))
        label = UILabel(frame: CGRectMake(0, 0, 95, frame.height))
        label.text = caption
        label.font = UIFont(name: "HelveticaNeue-Thin", size: 20)
        //        label.shadowColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 0.8)
        //        label.shadowOffset = CGSizeMake(-0.5, 0.5)
        label.textAlignment = NSTextAlignment.Right
        label.textColor = UIColor.blackColor()
        labelBG.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        labelBG.addSubview(label)
        addSubview(labelBG)
    }
    func highlight(){
        if !isHilighted{
            //            label.shadowColor = UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 0.8)
            UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                self.sel_imgView.alpha = 1
                }, completion: { (complete) -> Void in
                    self.isHilighted = true
                    self.delegate?.animationCompl()
                    self.label.textColor = UIColor.whiteColor()
                    self.labelBG.backgroundColor = UIColor.blackColor()
            })
        }
    }
    func unhighlight(){
        if (isHilighted == true){
            UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                self.sel_imgView.alpha = 0
                }, completion: { (complete) -> Void in
                    self.isHilighted = false
                    self.delegate?.animationCompl()
                    self.label.textColor = UIColor.blackColor()
                    //            label.shadowColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 0.8)
                    self.labelBG.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
            })
        }
    }
    func enable(){
        if !isEnabled{
            self.bringSubviewToFront(self.backCircle)
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                self.backCircle.alpha = 1
                }) { (complete) -> Void in
                    self.isEnabled = true
                    self.animateBackground()
            }
        }
    }
    func animateBackground(){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.backCircle.transform = CGAffineTransformMakeScale(1.3, 1.3)
                }, completion: { (complete) -> Void in
                    UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                        self.backCircle.transform = CGAffineTransformMakeScale(1, 1)
                        }, completion: { (complete) -> Void in
                            if (self.isEnabled == true)
                            {
                                self.animateBackground()
                            }
                    })
            })
        })
    }
    func disable(){
        isEnabled = false
    }
}
