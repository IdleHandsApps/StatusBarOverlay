//
//  StatusBarWindow.swift
//  StatusBarOverlay
//
//  Created by Fraser Scott-Morrison on 10/10/17.
//  Copyright © 2017 IdleHandsApps. All rights reserved.
//

import UIKit
import Alamofire

class StatusBarWindow: UIWindow {
    
    fileprivate static var shared = StatusBarWindow()
    fileprivate static var hasMessage: Bool = false
    fileprivate static var messageHandler:(() -> Void)?
    fileprivate static var actionHandler:(() -> Void)?
    
    fileprivate var noConnectionViewController:StatusBarViewController?
    fileprivate var reachability:NetworkReachabilityManager?
    
    public static let networkChangedToReachableNotification = Notification.Name(rawValue: "networkChangedToReachable")
    public static var defaultBackgroundColor = UIColor.black
    public static var defaultTextColor = UIColor.white
    public static var host: String!
    public static var isReachable = true
    public static var preferredStatusBarStyle = UIStatusBarStyle.default
    public static var prefersStatusBarHidden = false
    public static var preferredStatusBarUpdateAnimation = UIStatusBarAnimation.none
    public static weak var topViewController: UIViewController?

    init() {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 64)
        super.init(frame: frame)
        self.initialise()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialise()
    }
    
    func initialise() {
        
        assert(StatusBarWindow.host != nil, "StatusBarWindow.host must be set to your api path")
        
        if let infoPlist = Bundle.main.infoDictionary {
            if let statusBarHidden = infoPlist["UIStatusBarHidden"] as? Bool {
                StatusBarWindow.prefersStatusBarHidden = statusBarHidden
            }
            if let statusBarStyle = infoPlist["UIStatusBarStyle"] as? String {
                if statusBarStyle == "UIStatusBarStyleLightContent" {
                    StatusBarWindow.preferredStatusBarStyle = .lightContent
                }
                else if statusBarStyle == "UIStatusBarStyleDefault" {
                    StatusBarWindow.preferredStatusBarStyle = .default
                }
            }
        }
        
        var frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 64)
        self.noConnectionViewController = StatusBarViewController(nibName: "StatusBarViewController", bundle: nil)
        self.noConnectionViewController!.view.frame = frame
        
        self.windowLevel = UIWindowLevelStatusBar + 1
        self.addSubview((self.noConnectionViewController!.view)!)
        
        frame.size.height = 0
        self.frame = frame
        
        self.reachability = NetworkReachabilityManager(host: StatusBarWindow.host)
        self.reachability?.listener = {(status: NetworkReachabilityManager.NetworkReachabilityStatus) -> () in
            self.networkStatusChanged(status, animated: true)
        }
        self.reachability?.startListening()
        
        self.noConnectionViewController?.messageButton.addTarget(self, action: #selector(StatusBarWindow.messageTapped(_:)), for: UIControlEvents.touchUpInside)
        self.noConnectionViewController?.actionButton.addTarget(self, action: #selector(StatusBarWindow.actionTapped(_:)), for: UIControlEvents.touchUpInside)
        self.noConnectionViewController?.statusBarButton.addTarget(self, action: #selector(StatusBarWindow.statusBarTapped(_:)), for: UIControlEvents.touchUpInside)
    }
    
    class func setStatusBarText(_ statusBarText: String?, backgroundColor: UIColor?) {

        StatusBarWindow.shared.noConnectionViewController?.customStatusBarText = statusBarText
        StatusBarWindow.shared.noConnectionViewController?.statusBarLabel.backgroundColor = backgroundColor != nil ? backgroundColor! : StatusBarWindow.defaultBackgroundColor
        
        StatusBarWindow.shared.updateIsReachable(StatusBarWindow.isReachable, animated: StatusBarWindow.isReachable)
    }
    
    func networkStatusChanged(_ status: NetworkReachabilityManager.NetworkReachabilityStatus, animated: Bool) {
        switch status {
        case .notReachable:
            StatusBarWindow.shared.updateIsReachable(false, animated: animated)
            break
        case .reachable:
            StatusBarWindow.shared.updateIsReachable(true, animated: animated)
            NotificationCenter.default.post(name: StatusBarWindow.networkChangedToReachableNotification, object: nil)
            break
        case .unknown:
            StatusBarWindow.shared.updateIsReachable(true, animated: animated)
            break
        }
    }
    
    class func showMessage(_ message: String?, animated: Bool, duration: Double = 0, actionName: String = "", actionHandler: (() -> Void)? = nil, messageHandler: (() -> Void)? = nil) {
        
        StatusBarWindow.shared.noConnectionViewController?.actionButton.isHidden = actionName.characters.count == 0
        StatusBarWindow.shared.noConnectionViewController?.actionButton.setTitle(actionName, for: .normal)
        StatusBarWindow.actionHandler = actionHandler
        StatusBarWindow.messageHandler = messageHandler

        StatusBarWindow.shared.noConnectionViewController?.messageLabel.text = message
        StatusBarWindow.hasMessage = message != nil
        
        //if let backgroundColor = UINavigationBar.appearance().barTintColor as UIColor! {
        //    StatusBarWindow.shared.noConnectionViewController?.backgroundView.backgroundColor = StatusBarWindow.getDarkenedColor(backgroundColor)
        //}
        // Kegstar
        StatusBarWindow.shared.noConnectionViewController?.backgroundView.backgroundColor = StatusBarWindow.defaultBackgroundColor
        
        if let reachability = StatusBarWindow.shared.reachability as NetworkReachabilityManager! {
            let status = reachability.networkReachabilityStatus
            StatusBarWindow.shared.networkStatusChanged(status, animated: animated)
        }
        
        if duration > 0 {
            if #available(iOS 10.0, *) {
                Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { timer in
                    self.removeMessage()
                }
            } else {
                Timer.scheduledTimer(timeInterval: duration, target: BlockOperation(block: {
                    self.removeMessage()
                }), selector: #selector(Operation.main), userInfo: nil, repeats: false)
            }
        }
    }

    func updateIsReachable(_ isReachable: Bool, animated: Bool) {
        StatusBarWindow.isReachable = isReachable
        self.isHidden = false
        
        if isReachable && StatusBarWindow.shared.noConnectionViewController?.customStatusBarText == nil {
            StatusBarWindow.shared.noConnectionViewController!.noConnectionBarConstraintHeight.constant = 0
            if StatusBarWindow.hasNotch() == false {
                StatusBarWindow.prefersStatusBarHidden = true
                StatusBarWindow.preferredStatusBarUpdateAnimation = animated ? UIStatusBarAnimation.slide : UIStatusBarAnimation.none
                UIView.animate(withDuration: animated ? 0.2 : 0, animations: {
                    StatusBarWindow.topViewController?.setNeedsStatusBarAppearanceUpdate()
                })
                //UIApplication.shared.setStatusBarHidden(true, with: animated ? UIStatusBarAnimation.slide : UIStatusBarAnimation.none)
            }
            
            UIView.animate(withDuration: animated ? 0.3 : 0, animations: { () -> Void in
                
                let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: StatusBarWindow.hasMessage ? 44 : 0)
                self.frame = frame
                self.layoutIfNeeded()
            })
        }
        else {
            StatusBarWindow.shared.noConnectionViewController?.statusBarLabel.textColor = StatusBarWindow.defaultTextColor
            // set custom status bar text, if any
            if StatusBarWindow.shared.noConnectionViewController?.customStatusBarText != nil && !isReachable {
                StatusBarWindow.shared.noConnectionViewController?.statusBarLabel.text = (StatusBarWindow.shared.noConnectionViewController?.customStatusBarText)! + " - No Connection"
            }
            else if StatusBarWindow.shared.noConnectionViewController?.customStatusBarText != nil {
                StatusBarWindow.shared.noConnectionViewController?.statusBarLabel.text = StatusBarWindow.shared.noConnectionViewController?.customStatusBarText!
            }
            else {
                StatusBarWindow.shared.noConnectionViewController?.statusBarLabel.text = "No Internet Connection"
            }
            
            StatusBarWindow.shared.noConnectionViewController!.noConnectionBarConstraintHeight.constant = 20
            StatusBarWindow.prefersStatusBarHidden = false
            StatusBarWindow.preferredStatusBarUpdateAnimation = animated ? UIStatusBarAnimation.slide : UIStatusBarAnimation.none
            UIView.animate(withDuration: animated ? 0.2 : 0, animations: {
                StatusBarWindow.topViewController?.setNeedsStatusBarAppearanceUpdate()
            })
            //UIApplication.shared.setStatusBarHidden(false, with: animated ? UIStatusBarAnimation.slide : UIStatusBarAnimation.none)
            
            UIView.animate(withDuration: animated ? 0.3 : 0, animations: { () -> Void in
                
                let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: StatusBarWindow.hasMessage ? 64 : 20)
                self.frame = frame
                self.layoutIfNeeded()
            })
        }
    }
    
    @IBAction func messageTapped(_ sender: UIButton) {
        
        if StatusBarWindow.messageHandler != nil {
            StatusBarWindow.messageHandler!()
        }
        
        StatusBarWindow.removeMessage()
    }
    
    @IBAction func actionTapped(_ sender: UIButton) {
        if StatusBarWindow.actionHandler != nil {
            StatusBarWindow.actionHandler!()
        }
        else if StatusBarWindow.messageHandler != nil {
            StatusBarWindow.messageHandler!()
        }
        
        StatusBarWindow.removeMessage()
    }
    
    class func removeMessage() {
        StatusBarWindow.hasMessage = false
        
        if let reachability = StatusBarWindow.shared.reachability as NetworkReachabilityManager! {
            StatusBarWindow.shared.networkStatusChanged(reachability.networkReachabilityStatus, animated: true)
        }
    }
    
    @IBAction func statusBarTapped(_ sender: UIButton) {
        if let reachability = self.reachability as NetworkReachabilityManager! {
            StatusBarWindow.shared.networkStatusChanged(reachability.networkReachabilityStatus, animated: true)
        }
    }
    
    class func getDarkenedColor(_ color: UIColor?) -> UIColor {
        var red:CGFloat = 0
        var green:CGFloat = 0
        var blue:CGFloat = 0
        var alpha:CGFloat = 0
        color?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        red += 0.4
        green += 0.4
        blue += 0.4
        
        red = max(min(1.0, red), 0)
        green = max(min(1.0, green), 0)
        blue = max(min(1.0, blue), 0)
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
    
    public static func hasNotch() -> Bool {
        var hasNotch = false
        if #available(iOS 11.0, *) {
            if self.shared.safeAreaInsets != UIEdgeInsets.zero {
                hasNotch = true
            }
        }
        return hasNotch
    }
}
