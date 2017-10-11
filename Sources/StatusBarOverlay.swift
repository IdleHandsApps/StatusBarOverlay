//
//  StatusBarOverlay.swift
//  StatusBarOverlay
//
//  Created by Fraser Scott-Morrison on 10/10/17.
//  Copyright © 2017 IdleHandsApps. All rights reserved.
//

import UIKit
import Alamofire

@objc public class StatusBarOverlay: UIWindow {
    
    fileprivate static var shared = StatusBarOverlay()
    fileprivate static var hasMessage: Bool = false
    fileprivate static var messageHandler:(() -> Void)?
    fileprivate static var actionHandler:(() -> Void)?
    
    fileprivate var statusBarViewController:StatusBarViewController?
    fileprivate var reachability:NetworkReachabilityManager?
    
    private static let podBundle = Bundle(for: StatusBarOverlay.classForCoder())
    private static let bundleUrl = StatusBarOverlay.podBundle.url(forResource: "StatusBarOverlay", withExtension: "bundle")
    public static let bundle = StatusBarOverlay.bundleUrl != nil ? Bundle(url: StatusBarOverlay.bundleUrl!) : nil // set to use your own bundle
    
    public static let networkChangedToReachableNotification = Notification.Name(rawValue: "networkChangedToReachable")
    public static var defaultBackgroundColor = UIColor.black
    public static var defaultTextColor = UIColor.white
    public static var defaultFont = UIFont.boldSystemFont(ofSize: 14)
    public static var defaultText = "No Internet Connection"
    public static var defaultNotchText = "No Data"
    public static var host: String!
    public static var isReachable = true
    public static var preferredStatusBarStyle = UIStatusBarStyle.default
    public static var prefersStatusBarHidden = false
    public static var preferredStatusBarUpdateAnimation = UIStatusBarAnimation.none
    public static weak var topViewController: UIViewController?
    
    private init() {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 88)
        super.init(frame: frame)
        self.initialise()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialise()
    }
    
    func initialise() {
        
        assert(StatusBarOverlay.host != nil, "StatusBarOverlay.host must be set to your api path")
        
        if let infoPlist = Bundle.main.infoDictionary {
            if let statusBarHidden = infoPlist["UIStatusBarHidden"] as? Bool {
                StatusBarOverlay.prefersStatusBarHidden = statusBarHidden
            }
            if let statusBarStyle = infoPlist["UIStatusBarStyle"] as? String {
                if statusBarStyle == "UIStatusBarStyleLightContent" {
                    StatusBarOverlay.preferredStatusBarStyle = .lightContent
                }
                else if statusBarStyle == "UIStatusBarStyleDefault" {
                    StatusBarOverlay.preferredStatusBarStyle = .default
                }
            }
        }
        
        var frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 88)
        self.statusBarViewController = StatusBarViewController(nibName: "StatusBarViewController", bundle: StatusBarOverlay.bundle)
        self.statusBarViewController?.view.frame = frame
        self.statusBarViewController?.setStatusBarFont(font: StatusBarOverlay.defaultFont)
        self.statusBarViewController?.setStatusBarIcon(image: UIImage(named: "NoWifi", in: StatusBarOverlay.bundle, compatibleWith: nil)!)
        
        self.windowLevel = UIWindowLevelStatusBar + 1
        self.addSubview((self.statusBarViewController!.view)!)
        
        frame.size.height = 0
        self.frame = frame
        
        self.reachability = NetworkReachabilityManager(host: StatusBarOverlay.host)
        self.reachability?.listener = {(status: NetworkReachabilityManager.NetworkReachabilityStatus) -> () in
            self.networkStatusChanged(status, animated: true)
        }
        self.reachability?.startListening()
        
        self.statusBarViewController?.messageButton.addTarget(self, action: #selector(StatusBarOverlay.messageTapped(_:)), for: UIControlEvents.touchUpInside)
        self.statusBarViewController?.actionButton.addTarget(self, action: #selector(StatusBarOverlay.actionTapped(_:)), for: UIControlEvents.touchUpInside)
        self.statusBarViewController?.statusBarButton.addTarget(self, action: #selector(StatusBarOverlay.statusBarTapped(_:)), for: UIControlEvents.touchUpInside)
    }
    
    public class func setStatusBarText(_ statusBarText: String?, backgroundColor: UIColor?) {
        
        StatusBarOverlay.shared.statusBarViewController?.setStatusBarText(text: statusBarText)
        StatusBarOverlay.shared.statusBarViewController?.setStatusBarFont(font: StatusBarOverlay.defaultFont)
        StatusBarOverlay.shared.statusBarViewController?.setStatusBarBackgroundColor(color: backgroundColor != nil ? backgroundColor! : StatusBarOverlay.defaultBackgroundColor)
        
        StatusBarOverlay.shared.updateIsReachable(StatusBarOverlay.isReachable, animated: StatusBarOverlay.isReachable)
    }
    
    func networkStatusChanged(_ status: NetworkReachabilityManager.NetworkReachabilityStatus, animated: Bool) {
        switch status {
        case .notReachable:
            StatusBarOverlay.shared.updateIsReachable(false, animated: animated)
            break
        case .reachable:
            StatusBarOverlay.shared.updateIsReachable(true, animated: animated)
            NotificationCenter.default.post(name: StatusBarOverlay.networkChangedToReachableNotification, object: nil)
            break
        case .unknown:
            StatusBarOverlay.shared.updateIsReachable(true, animated: animated)
            break
        }
    }
    
    public class func showMessage(_ message: String?, animated: Bool, duration: Double = 0, actionName: String = "", actionHandler: (() -> Void)? = nil, messageHandler: (() -> Void)? = nil) {
        
        StatusBarOverlay.shared.statusBarViewController?.actionButton.isHidden = actionName.characters.count == 0
        StatusBarOverlay.shared.statusBarViewController?.actionButton.setTitle(actionName, for: .normal)
        StatusBarOverlay.actionHandler = actionHandler
        StatusBarOverlay.messageHandler = messageHandler
        
        StatusBarOverlay.shared.statusBarViewController?.setMessageBarText(text: message)
        StatusBarOverlay.hasMessage = message != nil
        
        StatusBarOverlay.shared.statusBarViewController?.setMessageBarBackgroundColor(color: StatusBarOverlay.defaultBackgroundColor)
        
        if let reachability = StatusBarOverlay.shared.reachability as NetworkReachabilityManager! {
            let status = reachability.networkReachabilityStatus
            StatusBarOverlay.shared.networkStatusChanged(status, animated: animated)
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
        StatusBarOverlay.isReachable = isReachable
        self.isHidden = false
        self.statusBarViewController?.setHasNotch(StatusBarOverlay.hasNotch())
        
        if isReachable && StatusBarOverlay.shared.statusBarViewController?.customStatusBarText == nil {
            StatusBarOverlay.shared.statusBarViewController!.statusBarConstraintHeight.constant = 0
            if StatusBarOverlay.hasNotch() == false {
                StatusBarOverlay.prefersStatusBarHidden = true
                StatusBarOverlay.preferredStatusBarUpdateAnimation = animated ? UIStatusBarAnimation.slide : UIStatusBarAnimation.none
                UIView.animate(withDuration: animated ? 0.2 : 0, animations: {
                    StatusBarOverlay.topViewController?.setNeedsStatusBarAppearanceUpdate()
                })
                //UIApplication.shared.setStatusBarHidden(true, with: animated ? UIStatusBarAnimation.slide : UIStatusBarAnimation.none)
            }
            
            UIView.animate(withDuration: animated ? 0.3 : 0, animations: { () -> Void in
                
                let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: StatusBarOverlay.hasMessage ? 44 : 0)
                self.frame = frame
                self.layoutIfNeeded()
            })
        }
        else {
            StatusBarOverlay.shared.statusBarViewController?.setStatusBarTextColor(color: StatusBarOverlay.defaultTextColor)
            // set custom status bar text, if any
            if StatusBarOverlay.shared.statusBarViewController?.customStatusBarText != nil && !isReachable {
                StatusBarOverlay.shared.statusBarViewController?.setStatusBarText(text: (StatusBarOverlay.shared.statusBarViewController?.customStatusBarText)! + (StatusBarOverlay.hasNotch() ? "" : " - \(StatusBarOverlay.defaultText)"))
            }
            else if StatusBarOverlay.shared.statusBarViewController?.customStatusBarText != nil {
                StatusBarOverlay.shared.statusBarViewController?.setStatusBarText(text: StatusBarOverlay.shared.statusBarViewController?.customStatusBarText)
            }
            else {
                StatusBarOverlay.shared.statusBarViewController?.setStatusBarText(text: (StatusBarOverlay.hasNotch() ? StatusBarOverlay.defaultNotchText : StatusBarOverlay.defaultText))
            }
            
            let statusBarHeight: CGFloat = StatusBarOverlay.hasNotch() ? 44 :  20
            
            StatusBarOverlay.shared.statusBarViewController!.statusBarConstraintHeight.constant = statusBarHeight
            StatusBarOverlay.prefersStatusBarHidden = false
            StatusBarOverlay.preferredStatusBarUpdateAnimation = animated ? UIStatusBarAnimation.slide : UIStatusBarAnimation.none
            UIView.animate(withDuration: animated ? 0.2 : 0, animations: {
                StatusBarOverlay.topViewController?.setNeedsStatusBarAppearanceUpdate()
            })
            //UIApplication.shared.setStatusBarHidden(false, with: animated ? UIStatusBarAnimation.slide : UIStatusBarAnimation.none)
            
            UIView.animate(withDuration: animated ? 0.3 : 0, animations: { () -> Void in
                
                let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: statusBarHeight + (StatusBarOverlay.hasMessage ? 44 : 0))
                self.frame = frame
                self.layoutIfNeeded()
            })
        }
    }
    
    @IBAction func messageTapped(_ sender: UIButton) {
        
        if StatusBarOverlay.messageHandler != nil {
            StatusBarOverlay.messageHandler!()
        }
        
        StatusBarOverlay.removeMessage()
    }
    
    @IBAction func actionTapped(_ sender: UIButton) {
        if StatusBarOverlay.actionHandler != nil {
            StatusBarOverlay.actionHandler!()
        }
        else if StatusBarOverlay.messageHandler != nil {
            StatusBarOverlay.messageHandler!()
        }
        
        StatusBarOverlay.removeMessage()
    }
    
    public class func removeMessage() {
        StatusBarOverlay.hasMessage = false
        
        if let reachability = StatusBarOverlay.shared.reachability as NetworkReachabilityManager! {
            StatusBarOverlay.shared.networkStatusChanged(reachability.networkReachabilityStatus, animated: true)
        }
    }
    
    @IBAction func statusBarTapped(_ sender: UIButton) {
        if let reachability = self.reachability as NetworkReachabilityManager! {
            StatusBarOverlay.shared.networkStatusChanged(reachability.networkReachabilityStatus, animated: true)
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
    
    public class func hasNotch() -> Bool {
        var hasNotch = false
        if #available(iOS 11.0, *) {
            if self.shared.safeAreaInsets != UIEdgeInsets.zero {
                hasNotch = true
            }
        }
        return hasNotch
    }
}
