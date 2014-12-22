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
    var isActive: Bool!
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    init(frame: CGRect, img: UIImage!, hilight_img: UIImage!, func_name: String!){
        super.init(frame: frame)
        isActive = false
        imgView = UIImageView(frame: CGRectMake(0, 0, frame.width, frame.height))
        imgView.image = img
        addSubview(imgView)
        sel_imgView = UIImageView(frame: CGRectMake(0, 0, frame.width, frame.height))
        sel_imgView.image = hilight_img
        addSubview(sel_imgView)
        sel_imgView.alpha = 0
        caption = func_name
        label = UILabel(frame: CGRectMake(-150, 0, 140, frame.height))
        label.text = caption
        label.font = UIFont(name: "HelveticaNeue-Thin", size: 20)
        label.shadowColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 0.8)
        label.shadowOffset = CGSizeMake(-0.5, 0.5)
        label.textAlignment = NSTextAlignment.Right
        label.textColor = UIColor.whiteColor()
        
        addSubview(label)
    }
    func makeActive(){
        if !isActive{
            label.textColor = UIColor.blackColor()
            label.shadowColor = UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 0.8)
            UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                self.sel_imgView.alpha = 1
                }, completion: { (complete) -> Void in
                    self.isActive = true
                    self.delegate?.animationCompl()
            })
        }
    }
    func makeInactive(){
        if (isActive == true){
            label.textColor = UIColor.whiteColor()
            label.shadowColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 0.8)
            UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                self.sel_imgView.alpha = 0
                }, completion: { (complete) -> Void in
                    self.isActive = false
                    self.delegate?.animationCompl()
            })
        }
    }
}
