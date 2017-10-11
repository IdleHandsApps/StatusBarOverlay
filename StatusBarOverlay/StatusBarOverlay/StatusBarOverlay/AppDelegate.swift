//
//  AppDelegate.swift
//  StatusBarOverlay
//
//  Created by Fraser on 10/10/17.
//  Copyright © 2017 IdleHandsApps. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // need to set StatusBarOverlay.host so network can be detected
        StatusBarOverlay.host = "example.com"
        
        // If you app hides the status bar, you might want it to show just for devices with a notch, eg iPhone X
        if StatusBarOverlay.hasNotch() {
            StatusBarOverlay.prefersStatusBarHidden = false
        }
        
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {

        // If your app shows StatusBarOverlay messages, its best to hide them here
        StatusBarOverlay.showMessage(nil, animated: false)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {

        // If your app shows StatusBarOverlay messages, its best to hide them here
        StatusBarOverlay.showMessage(nil, animated: false)
    }
}

