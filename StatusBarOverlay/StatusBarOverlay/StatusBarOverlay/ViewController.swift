//
//  ViewController.swift
//  StatusBarOverlay
//
//  Created by Fraser on 10/10/17.
//  Copyright © 2017 IdleHandsApps. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        StatusBarWindow.topViewController = self // so status bar can be updated at any time
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return StatusBarWindow.preferredStatusBarStyle
    }
    
    override var prefersStatusBarHidden: Bool {
        return StatusBarWindow.prefersStatusBarHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return StatusBarWindow.preferredStatusBarUpdateAnimation
    }


}

