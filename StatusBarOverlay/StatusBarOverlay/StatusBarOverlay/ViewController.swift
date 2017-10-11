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
        
        StatusBarOverlay.topViewController = self // so status bar can be updated at any time
        
        //StatusBarOverlay.showMessage(nil, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        

        StatusBarOverlay.showMessage(nil, animated: false)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return StatusBarOverlay.preferredStatusBarStyle
    }
    
    override var prefersStatusBarHidden: Bool {
        return StatusBarOverlay.prefersStatusBarHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return StatusBarOverlay.preferredStatusBarUpdateAnimation
    }


}

