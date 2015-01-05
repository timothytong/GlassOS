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
    var disableView:UIView!
    var curActivePromptWindow: PromptBox?
    var promptBoxIsCurrentlyVisible = false
    var promptBoxQueue: Array<PromptBox>!
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
        setNeedsStatusBarAppearanceUpdate()
        pageView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
        if let pCont = controller{
            view.addSubview(pageView!)
            pageView!.addSubview(pCont.view)
        }
        disableView = UIView(frame: view.frame)
        disableView.backgroundColor = UIColor.clearColor()
        disableView.alpha = 0
//        disableView.userInteractionEnabled = false
        view.addSubview(disableView)
        promptBoxQueue = Array<PromptBox>()
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
    
    func disablePageAndShowDialog(promptWindow: PromptBox){
        if !promptBoxIsCurrentlyVisible{
            promptBoxIsCurrentlyVisible = true
            curActivePromptWindow = promptWindow
            disableView.addSubview(curActivePromptWindow!)
            disableView.bringSubviewToFront(curActivePromptWindow!)
            UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.disableView.alpha = 0.75
                }) { (complete) -> Void in
                    SessionCenter.sharedInstance.disableFullControl()
            }
        }
        else{
            promptBoxQueue.append(promptWindow)
        }
    }
    
    func dismissCurrentPromptWindow(){
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.disableView.alpha = 0
        }) { (complete) -> Void in
            SessionCenter.sharedInstance.enableFullControl()
            self.promptBoxIsCurrentlyVisible = false
            self.curActivePromptWindow!.removeFromSuperview()
            println("Array count: \(self.promptBoxQueue.count)")
            if self.promptBoxQueue.count != 0{
                self.curActivePromptWindow = self.promptBoxQueue.removeAtIndex(0)
                self.disablePageAndShowDialog(self.curActivePromptWindow!)
            }

        }
    }
    /*
    func addObservers(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handle:", name: SVProgressHUDWillAppearNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handle:", name: SVProgressHUDDidAppearNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handle:", name: SVProgressHUDWillDisappearNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handle:", name: SVProgressHUDDidDisappearNotification, object: nil)
        
        SVProgressHUD.setFont(UIFont(name: "HelveticaNeue-Thin", size: 20))
    }
*/
    
    func handle(notif:NSNotification){
        //        NSLog("Notification recieved: \(notif.name)");
        //        NSLog("Status user info key: \(notif.userInfo?[SVProgressHUDStatusUserInfoKey])")
    }
}
