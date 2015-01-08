//
//  AppDelegate.swift
//  GlassOS
//
//  Created by Timothy Tong on 2014-12-11.
//  Copyright (c) 2014 Timothy Tong. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PromptBoxDelegate, RootControllerDelegate {
    
    var window: UIWindow?
    var mainController: UIViewController?
    var rootController: RootController?
    var camController: CamHomeController?
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.backgroundColor = UIColor.whiteColor()
        mainController = MainController()
        rootController = RootController(nibName: nil, bundle: nil)
        rootController!.useController(mainController)
        rootController!.delegate = self
        camController = CamHomeController()
        window!.rootViewController = rootController
        window?.makeKeyAndVisible()
        return true
    }
    
    func transitionToCam(){
        camController = CamHomeController()
        camController!.delegate = rootController
        rootController?.transitionToCamController(camController)
    }
    
    func disablePageAndShowDialog(dialogWindow: PromptBox){
        dialogWindow.delegate = self
        rootController?.disablePageAndShowDialog(dialogWindow)
    }
    
    func disablePageAndDisplayNotice(title: String, msg: String){
        var noticeWindow = PromptBox(screenSize: window!.frame.size, title: title, msg: msg, buttons: ["OK"],name:"notice")
        noticeWindow.delegate = self
        rootController?.disablePageAndShowDialog(noticeWindow)
    }
    func promptBoxButtonClicked(button: String, boxName name:String!) {
        println("\(name) prompbox tapped, button of interest: \"\(button)\"")
        switch name{
        case "selrect":
            if button == "Yes"{
                self.rootController!.dismissCurrentPromptWindow()
                self.camController!.captureSelectionArea()
            }
        default:
            break;
        }
        
        if name == "notice"{
            if button == "OK"{
                rootController!.dismissCurrentPromptWindow()
            }
        }
        
    }
    func dismissActivePromptWindow(){
        rootController!.dismissCurrentPromptWindow()
    }
    func statusDismissed(){
        var statusCenter = StatusCenter.sharedInstance
        statusCenter.aStatusHasBeenDismissed()
    }
    func displayStatus(msg:String!, labelSize size:CGSize, isImportant important:Bool){
        rootController?.displayStatus(msg, labelSize: size, isImportant: important)
    }
    func dismissStatusWindow(){
        rootController?.dismissStatusView()
    }
    func rebootOS(){
        camController = nil
        camController = CamHomeController()
        transitionToCam()
    }
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

