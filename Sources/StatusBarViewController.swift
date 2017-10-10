//
//  StatusBarWindow.swift
//  StatusBarOverlay
//
//  Created by Fraser Scott-Morrison on 10/10/17.
//  Copyright © 2017 IdleHandsApps. All rights reserved.
//

import UIKit

class StatusBarViewController: UIViewController {

    @IBOutlet var backgroundView: UIView!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var messageButton: UIButton!
    @IBOutlet var actionButton: UIButton!
    @IBOutlet var statusBarButton: UIButton!
    @IBOutlet var statusBarLabel: UILabel!
    @IBOutlet var noConnectionBarConstraintHeight: NSLayoutConstraint!
    
    var customStatusBarText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.messageButton.setBackgroundImage(StatusBarViewController.imageWithColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)), for: UIControlState.selected)
        self.messageButton.setBackgroundImage(StatusBarViewController.imageWithColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)), for: UIControlState.highlighted)
        self.actionButton.isHidden = true
    }

    class func imageWithColor(_ color: UIColor) -> UIImage {
        let rect: CGRect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

}
