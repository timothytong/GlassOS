//
//  Cursor.swift
//  GlassOS
//
//  Created by Timothy Tong on 2014-12-23.
//  Copyright (c) 2014 Timothy Tong. All rights reserved.
//

import UIKit
@objc protocol CursorDelegate{
    func moveSelRectToPoint(point:CGPoint)
    func positionSelRectAtPoint(point: CGPoint)
    func finishedSelection()
}
class Cursor: UIView {
    var delegate: CursorDelegate?
    private var startingPoint: CGPoint!
    private var canDrag = false
    override init() {
        super.init(frame:CGRectMake(-6, -6, 12, 12))
        var path = UIBezierPath(roundedRect: CGRectMake(0, 0, 12, 12), cornerRadius: 6)
        var mask = CAShapeLayer()
        mask.path = path.CGPath
        layer.mask = mask
        backgroundColor = UIColor(red: 72/255, green: 193/255, blue: 240/255, alpha: 0.3)
        alpha = 0
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func color(newColor:UIColor){
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.backgroundColor = newColor
            }) { (complete) -> Void in
        }
    }
    
    func show(){
        UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.alpha = 1
            }) { (complete) -> Void in
        }
    }
    
    func hide(){
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.alpha = 0
            }) { (complete) -> Void in
                
        }
    }
    
    func startDragging(startPoint:CGPoint){
        startingPoint = startPoint
        canDrag = true
        delegate?.positionSelRectAtPoint(startingPoint)
    }
    func moveWithTranslationPoint(point:CGPoint){
        // when calling this method, check if cursor is still in bounds!
        frame.origin.x = startingPoint.x + point.x - 6
        frame.origin.y = startingPoint.y + point.y - 6
        if canDrag{
            delegate?.moveSelRectToPoint(CGPointMake(frame.origin.x + 6, frame.origin.y + 6))
        }
    }
    
    func endDragging(){
        // when the user stops performing that particular gesture. (e.g. stops squeezing their fist.)
        canDrag = false
        delegate?.finishedSelection()
    }
    
    func endDraggingAndCaptureArea()->UIImage{
        var image = UIImage()
        return image
    }
}
