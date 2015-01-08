//
//  RootController.swift
//  GlassOS
//
//  Created by Timothy Tong on 2014-12-11.
//  Copyright (c) 2014 Timothy Tong. All rights reserved.
//

import UIKit
@objc protocol RootControllerDelegate{
    func statusDismissed()
}
class RootController: UIViewController, CamHomeControllerDelegate {
    private var controller:UIViewController?
    private var pageView:UIView?
    private var notificationBox: NotificationBox!
    private var disableView:UIView!
    private var curActivePromptWindow: PromptBox?
    private var promptBoxIsCurrentlyVisible = false
    private var promptBoxQueue: Array<PromptBox>!
    private var progressBar: UIProgressView!
    private var progressText: UILabel!
    private var statusView: UIView!
    private var aStatusIsActive = false
    private var statusLabel: UILabel!
    private var axillaryLbl: UILabel!
    var delegate: RootControllerDelegate?
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
        view.addSubview(disableView)
        promptBoxQueue = Array<PromptBox>()
        notificationBox = NotificationBox(frame: CGRectMake(view.frame.width - 110, 10, 100, 60))
        progressBar = UIProgressView(progressViewStyle: UIProgressViewStyle.Default)
        progressBar.frame = CGRectMake(view.frame.width / 2 - 100, view.frame.height/2 - 10, 200, 20)
        progressBar.tintColor = UIColor.blackColor()
        progressBar.setProgress(0, animated: false)
        progressBar.alpha = 0
        view.addSubview(progressBar)
        progressText = UILabel(frame: CGRectMake(5, view.frame.height/2 - 50, view.frame.width - 10, 40))
        progressText.text = ""
        progressText.font = UIFont(name: "HelveticaNeue-Thin", size: 25)
        progressText.textAlignment = .Center
        view.addSubview(progressText)
        view.sendSubviewToBack(progressText)
        statusView = UIView(frame: CGRectMake(5, 5, 0, 0))
        statusView.clipsToBounds = true
        statusLabel = UILabel()
        statusLabel.textAlignment = .Center
        statusLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 25)
        statusView.addSubview(statusLabel)
        statusLabel.numberOfLines = 0
        statusLabel.lineBreakMode = .ByWordWrapping
        axillaryLbl = UILabel()
        view.addSubview(statusView)
    }
    override func didReceiveMemoryWarning() {
        if (self.pageView != nil){
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                var statusCenter = StatusCenter.sharedInstance
                statusCenter.displayImportantStatus("Memory limit reached, rebooting.")
                UIView.animateWithDuration(0.35, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                    self.pageView!.alpha = 0
                    }, completion: { (complete) -> Void in
                        let subviews : Array = self.pageView!.subviews
                        for subview in subviews as [UIView]{
                            subview.removeFromSuperview()
                        }
                        let appDel = UIApplication.sharedApplication().delegate as AppDelegate
                        appDel.rebootOS()
                })
                self.progressBar.setProgress(0, animated: false)
                self.progressText.text = "Reinitializing."
                
            })
        }
        
        
    }
    func transitionToCamController(controller:UIViewController?){
        UIView.animateWithDuration(1, delay: 0.3, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.pageView!.alpha = 0
            }) { (complete) -> Void in
                self.progressBar.alpha = 1
                self.controller = controller
                let subviews : Array = self.pageView!.subviews
                for subview in subviews as [UIView]{
                    subview.removeFromSuperview()
                }
                self.pageView!.addSubview(controller!.view)
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
                self.curActivePromptWindow = nil
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
    func CameraSessionDidBegin() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.animateWithDuration(0.6, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.pageView!.alpha = 1
                self.progressBar.alpha = 0
                }) { (complete) -> Void in
            }
        })
        
    }
    func setProgress(num: Float){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.progressBar.setProgress(num, animated: true)
            if num >= 0 && num < 0.2{
                self.progressText.text = "Initializing."
            }
            else if num >= 0.4 && num < 0.5{
                self.progressText.text = "Preparing UI."
            }
            else if num >= 0.5 && num < 0.8{
                self.progressText.text = "Configuring Camera."
            }
            else{
                self.progressText.text = "Finishing Preparations."
            }
        })
    }
    func displayStatus(msg:String, labelSize size:CGSize){
        println("Displaying status.")
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if !self.aStatusIsActive{
                self.statusView.frame = CGRectMake(5, 5, 3, 0)
                self.aStatusIsActive = true
                self.statusLabel.frame = CGRectMake(5, size.height / 2, size.width, size.height)
                self.statusLabel.text = msg
                self.statusLabel.alpha = 0
                self.statusView.backgroundColor = UIColor.whiteColor()
                UIView.animateWithDuration(0.3, delay: 0.4, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                    self.statusView.frame = CGRectMake(5, 5, 3, size.height + 10)
                    }, completion: { (complete) -> Void in
                        UIView.animateWithDuration(0.15, animations: { () -> Void in
                            self.statusView.alpha = 0
                            }, completion: { (complete) -> Void in
                                UIView.animateWithDuration(0.15, animations: { () -> Void in
                                    self.statusView.alpha = 0.8
                                    }, completion: { (complete) -> Void in
                                        UIView.animateWithDuration(0.15, animations: { () -> Void in
                                            self.statusView.alpha = 0
                                            }, completion: { (complete) -> Void in
                                                UIView.animateWithDuration(0.15, animations: { () -> Void in
                                                    self.statusView.alpha = 0.8
                                                    }, completion: { (complete) -> Void in
                                                        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                                                            self.statusView.frame = CGRectMake(5, 5, size.width + 10, size.height + 10)
                                                            }, completion: { (complete) -> Void in
                                                                UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseIn, animations: { () -> Void in
                                                                    self.statusLabel.alpha = 1
                                                                    var offset = self.statusLabel.frame.origin.y - 5
                                                                    self.statusLabel.transform = CGAffineTransformMakeTranslation(0, -offset)
                                                                    }, completion: { (complete) -> Void in
                                                                        let timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "canAcceptAnotherStatus", userInfo: nil, repeats: false)
                                                                })
                                                        })
                                                })
                                                
                                        })
                                })
                        })
                })
            }
            else{
                println("replacing status labels.")
                if size.width > self.statusLabel.frame.size.width{
                    var newWidth = size.width + 10
                    UIView.animateWithDuration(0.15, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                        self.statusView.frame = CGRectMake(self.statusView.frame.origin.x, self.statusView.frame.origin.y, newWidth, self.statusView.frame.height)
                        }, completion: { (complete) -> Void in
                            if size.height > self.statusLabel.frame.size.height{
                                var newHeight = size.height + 10
                                UIView.animateWithDuration(0.15, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                                    self.statusView.frame = CGRectMake(self.statusView.frame.origin.x, self.statusView.frame.origin.y, newWidth, newHeight)
                                    }, completion: { (complete) -> Void in
                                        let timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "canAcceptAnotherStatus", userInfo: nil, repeats: false)
                                })
                                
                            }
                    })
                }
                self.axillaryLbl.frame = CGRectMake(5, size.height / 2, size.width, size.height)
                self.axillaryLbl.alpha = 0
                self.axillaryLbl.text = msg
                var frame = self.axillaryLbl.frame
                var offset = self.axillaryLbl.frame.origin.y - 5
                UIView.animateWithDuration(0.2, delay: 0.2, options: .CurveEaseIn, animations: { () -> Void in
                    self.statusLabel.transform = CGAffineTransformMakeTranslation(0, -offset)
                    self.statusLabel.alpha = 0
                    self.axillaryLbl.transform = CGAffineTransformMakeTranslation(0, -offset)
                    self.axillaryLbl.alpha = 1
                    }, completion: { (complete) -> Void in
                        self.statusLabel.text = self.axillaryLbl.text
                        self.statusLabel.alpha = 1
                        self.axillaryLbl.alpha = 0
                        self.statusLabel.frame = self.axillaryLbl.frame
                        self.axillaryLbl.frame = frame
                })
            }
        })
        
    }
    func canAcceptAnotherStatus(){
        self.delegate?.statusDismissed()

    }
    func dismissStatusView(){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.statusView.frame = CGRectMake(self.statusView.frame.origin.x, self.statusView.frame.origin.y, 3, self.statusView.frame.height)
                }) { (complete) -> Void in
                    UIView.animateWithDuration(0.2, animations: { () -> Void in
                        self.statusView.alpha = 0
                    })
                    self.aStatusIsActive = false
            }

        })
        
    }
}
