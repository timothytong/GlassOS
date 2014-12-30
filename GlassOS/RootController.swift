//
//  RootController.swift
//  GlassOS
//
//  Created by Timothy Tong on 2014-12-11.
//  Copyright (c) 2014 Timothy Tong. All rights reserved.
//

import UIKit

class RootController: UIViewController {
    var controller:UIViewController?
    var pageView:UIView?
    var notificationBox: NotificationBox!
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override required init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    func useController(controller: UIViewController!){
        controller.view.frame = CGRectMake(0, 0, controller.view.frame.width, controller.view.frame.height)
        
        self.controller = controller
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        self.pageView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
        if let pCont = self.controller{
            self.view.addSubview(self.pageView!)
            self.pageView!.addSubview(pCont.view)
        }
        notificationBox = NotificationBox(frame: CGRectMake(view.frame.width - 110, 10, 100, 60))
    }
    
    func transitionToPage(controller:UIViewController?){
        UIView.animateWithDuration(1, delay: 0.3, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.pageView!.alpha = 0
            }) { (complete) -> Void in
                
                self.controller = controller
                let subviews : Array = self.pageView!.subviews
                for subview in subviews as [UIView]{
                    subview.removeFromSuperview()
                }
                self.pageView!.addSubview(controller!.view)
                
                UIView.animateWithDuration(0.6, delay: 0.2, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                    self.pageView!.alpha = 1
                    }) { (complete) -> Void in
                }
                
                
        }
    }
}
