//
//  StatusBarExtensions.swift
//  StatusBarOverlay
//
//  Created by Fraser on 17/10/17.
//  Copyright © 2017 IdleHandsApps. All rights reserved.
//

import UIKit

extension UINavigationController {
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

extension UITabBarController {
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
