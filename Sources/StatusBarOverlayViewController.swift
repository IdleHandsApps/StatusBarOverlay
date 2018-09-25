//
//  StatusBarWindow.swift
//  StatusBarOverlay
//
//  Created by Fraser Scott-Morrison on 10/10/17.
//  Copyright © 2017 IdleHandsApps. All rights reserved.
//

import UIKit

class StatusBarOverlayViewController: UIViewController {
    
    @IBOutlet private var statusBarView: UIView!
    @IBOutlet private var statusBarNormalContainerView: UIView!
    @IBOutlet private var statusBarNotchContainerView: UIView!
    
    @IBOutlet private var backgroundView: UIView!
    @IBOutlet private var messageLabel: UILabel!
    @IBOutlet private var statusBarLabel: UILabel!
    @IBOutlet private var statusBarIcon: UIImageView!
    @IBOutlet private var statusBarNotchLabel: UILabel!
    @IBOutlet private var statusBarNotchIcon: UIImageView!
    
    @IBOutlet var messageButton: UIButton!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var arrowImageView: UIImageView!
    @IBOutlet var statusBarButton: UIButton!
    @IBOutlet var statusBarConstraintHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.messageButton.setBackgroundImage(StatusBarOverlayViewController.imageWithColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)), for: UIControl.State.selected)
        self.messageButton.setBackgroundImage(StatusBarOverlayViewController.imageWithColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)), for: UIControl.State.highlighted)
        self.arrowImageView.isHidden = true
    }
    
    public func setHasNotch(_ hasNotch: Bool) {
        self.statusBarNormalContainerView.isHidden = hasNotch
        self.statusBarNotchContainerView.isHidden = !hasNotch
    }
    
    public func setStatusBarFont(font: UIFont) {
        self.statusBarLabel.font = font
        self.statusBarNotchLabel.font = font
    }
    
    public func setStatusBarTextColor(color: UIColor) {
        self.statusBarLabel.textColor = color
        self.statusBarNotchLabel.textColor = color
        self.statusBarIcon.tintColor = color
        self.statusBarNotchIcon.tintColor = color
    }
    
    public func setStatusBarText(text: String?) {
        self.statusBarLabel.text = text
        self.statusBarNotchLabel.text = text
    }
    
    public func setStatusBarBackgroundColor(color: UIColor) {
        self.statusBarView.backgroundColor = color
    }
    
    public func setStatusBarIcon(image: UIImage) {
        self.statusBarIcon.image = image
        self.statusBarNotchIcon.image = image
    }
    
    public func setShowStatusBarIconHidden(_ isHidden: Bool) {
        self.statusBarIcon.isHidden = isHidden
        self.statusBarNotchIcon.isHidden = isHidden
    }
    
    public func setMessageBarText(text: String?) {
        self.messageLabel.text = text
    }
    
    public func setMessageBarBackgroundColor(color: UIColor) {
        self.backgroundView.backgroundColor = color
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

