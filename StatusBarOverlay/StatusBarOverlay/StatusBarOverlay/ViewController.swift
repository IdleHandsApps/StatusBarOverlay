//
//  ViewController.swift
//  StatusBarOverlay
//
//  Created by Fraser on 10/10/17.
//  Copyright © 2017 IdleHandsApps. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var prefersHiddenSwitch: UISwitch!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // so status bar can be updated at any time
        StatusBarOverlay.topViewController = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // TODO: I need to remove the necessity of this call
        StatusBarOverlay.showMessage(nil, animated: false)
        
        prefersHiddenSwitch.setOn(StatusBarOverlay.prefersStatusBarHidden, animated: false)
    }
    
    @IBAction func prefersHiddenChanged(_ sender: UISwitch) {
        StatusBarOverlay.prefersStatusBarHidden = prefersHiddenSwitch.isOn
    }
}

extension ViewController {
    // MARK: UIViewController status bar methods
    // Defer logic to StatusBarOverlay but override if needed
    
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

