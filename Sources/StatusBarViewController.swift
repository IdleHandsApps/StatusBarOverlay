//
//  StatusBarViewController.swift
//  StatusBarOverlay
//
//  Created by Fraser on 17/10/17.
//  Copyright © 2017 IdleHandsApps. All rights reserved.
//

import UIKit

open class StatusBarViewController: UIViewController {
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        StatusBarOverlay.topViewController = self
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return StatusBarOverlay.preferredStatusBarStyle
        }
    }
    
    open override var prefersStatusBarHidden: Bool {
        get {
            return StatusBarOverlay.prefersStatusBarHidden
        }
    }
    
    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        get {
            return StatusBarOverlay.preferredStatusBarUpdateAnimation
        }
    }
}
