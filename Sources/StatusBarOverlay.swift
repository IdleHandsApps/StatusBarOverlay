//
//  StatusBarOverlay.swift
//  StatusBarOverlay
//
//  Created by Fraser Scott-Morrison on 10/10/17.
//  Copyright © 2017 IdleHandsApps. All rights reserved.
//

import UIKit
import SystemConfiguration
import Reachability

@objc public class StatusBarOverlay: UIWindow {
    
    fileprivate static var shared = StatusBarOverlay()
    fileprivate static var hasMessage: Bool = false
    fileprivate static var messageHandler:(() -> Void)?
    
    fileprivate var statusBarOverlayViewController:StatusBarOverlayViewController?
    fileprivate var reachability = Reachability()
    
    private static let podBundle = Bundle(for: StatusBarOverlay.classForCoder())
    private static let bundleUrl = StatusBarOverlay.podBundle.url(forResource: "StatusBarOverlay", withExtension: "bundle")
    public static let bundle = StatusBarOverlay.bundleUrl != nil ? Bundle(url: StatusBarOverlay.bundleUrl!) : nil // set to use your own bundle
    
    public static let networkChangedToReachableNotification = Notification.Name(rawValue: "networkChangedToReachable")
    public static var defaultBackgroundColor = UIColor.black {
        didSet {
            StatusBarOverlay.shared.statusBarOverlayViewController?.setStatusBarBackgroundColor(color: StatusBarOverlay.defaultBackgroundColor)
        }
    }
    public static var defaultTextColor = UIColor.white {
        didSet {
            StatusBarOverlay.shared.statusBarOverlayViewController?.setStatusBarTextColor(color: StatusBarOverlay.defaultTextColor)
        }
    }
    public static var defaultFont = UIFont.boldSystemFont(ofSize: 14) {
        didSet {
            StatusBarOverlay.shared.statusBarOverlayViewController?.setStatusBarFont(font: StatusBarOverlay.defaultFont)
        }
    }
    public static var defaultText = "No Internet Connection" {
        didSet {
            StatusBarOverlay.shared.updateStatusBarText(isReachable: true)
        }
    }
    public static var defaultNotchText = "No Data" {
        didSet {
            StatusBarOverlay.shared.updateStatusBarText(isReachable: true)
        }
    }
    public static var customStatusBarText: String? {
        didSet {
            StatusBarOverlay.shared.updateStatusBarText(isReachable: true)
        }
    }
    
    @objc public private(set) static var hasNotch = false
    
    @objc public static var host: String! {
        didSet {
            _ = self.shared // initialise
            // then set the correct state on launch
            StatusBarOverlay.shared.update(isReachable: StatusBarOverlay.isReachable, animated: true)
        }
    }
    public static var isReachable: Bool {
        return self.shared.reachability?.connection != .none
    }
    
    @objc public static var preferredStatusBarStyle = UIStatusBarStyle.default {
        didSet {
            StatusBarOverlay.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    private static var prefersNoConnectionBarHidden = false {
        didSet {
            StatusBarOverlay.setNeedsStatusBarAppearanceUpdate()
        }
    }
    // Set to true at app launch if you want prefersStatusBarHidden to also hide status bar for devices with a notch, eg iPhone X
    // Keeping as false will keep status bar visible for devices with a notch, eg iPhone X
    @objc public static var prefersStatusBarNotchHidden = false {
        didSet {
            StatusBarOverlay.setNeedsStatusBarAppearanceUpdate()
        }
    }
    private static var _prefersStatusBarHidden = false
    @objc public static var prefersStatusBarHidden: Bool {
        get {
            return (StatusBarOverlay.hasNotch == false || prefersStatusBarNotchHidden) && _prefersStatusBarHidden && prefersNoConnectionBarHidden
        }
        set {
            _prefersStatusBarHidden = newValue
            StatusBarOverlay.setNeedsStatusBarAppearanceUpdate()
        }
    }
    @objc public static var preferredStatusBarUpdateAnimation = UIStatusBarAnimation.none {
        didSet {
            StatusBarOverlay.setNeedsStatusBarAppearanceUpdate()
        }
    }
    @objc public static weak var topViewController: UIViewController?
    
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
        
        StatusBarOverlay.setDefaultState()
        
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 0)
        self.statusBarOverlayViewController = StatusBarOverlayViewController(nibName: "StatusBarOverlayViewController", bundle: StatusBarOverlay.bundle)
        self.statusBarOverlayViewController?.view.frame = frame
        self.statusBarOverlayViewController?.setStatusBarFont(font: StatusBarOverlay.defaultFont)
        if let noWifi = UIImage(named: "NoWifi", in: StatusBarOverlay.bundle, compatibleWith: nil) {
            self.statusBarOverlayViewController?.setStatusBarIcon(image: noWifi)
        }
        
        self.windowLevel = UIWindow.Level.statusBar + 1
        self.rootViewController = self.statusBarOverlayViewController
        
        self.frame = frame
        
        /*self.reachability = NetworkReachabilityManager(host: StatusBarOverlay.host)
        self.reachability?.listener = {(status: NetworkReachabilityManager.NetworkReachabilityStatus) -> () in
            self.networkStatusChanged(status, animated: true)
        }
        self.reachability?.startListening()*/
        
        self.statusBarOverlayViewController?.messageButton.addTarget(self, action: #selector(StatusBarOverlay.messageTapped(_:)), for: UIControl.Event.touchUpInside)
        self.statusBarOverlayViewController?.closeButton.addTarget(self, action: #selector(StatusBarOverlay.closeTapped(_:)), for: UIControl.Event.touchUpInside)
        self.statusBarOverlayViewController?.statusBarButton.addTarget(self, action: #selector(StatusBarOverlay.statusBarTapped(_:)), for: UIControl.Event.touchUpInside)
        
        self.statusBarOverlayViewController?.setStatusBarTextColor(color: StatusBarOverlay.defaultTextColor)
        self.statusBarOverlayViewController?.setStatusBarBackgroundColor(color: StatusBarOverlay.defaultBackgroundColor)
        
        if #available(iOS 12.0, *) {
            if self.safeAreaInsets != UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0) {
                StatusBarOverlay.hasNotch = true
            }
        }
        else if #available(iOS 11.0, *) {
            if self.safeAreaInsets != UIEdgeInsets.zero {
                StatusBarOverlay.hasNotch = true
            }
        }
        
        reachability?.whenReachable = { reachability in
            StatusBarOverlay.shared.update(isReachable: true, animated: true)
        }
        reachability?.whenUnreachable = { _ in
            StatusBarOverlay.shared.update(isReachable: false, animated: true)
        }
        
        do {// Start the network status notifier
            try self.reachability?.startNotifier()
        } catch {
            print("Unable to start notifier")
        }

        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: OperationQueue.main) { note in
            StatusBarOverlay.shared.update(isReachable: StatusBarOverlay.isReachable, animated: true)
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.didChangeStatusBarFrameNotification, object: nil, queue: OperationQueue.main) { [weak self] note in
            DispatchQueue.main.async {
                // update window frame
                guard let strongSelf = self else { return }
                var height: CGFloat = StatusBarOverlay.isReachable ? 0 : (StatusBarOverlay.hasNotch ? 44 :  20)
                height += StatusBarOverlay.hasMessage ? 44 : 0
                strongSelf.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: height)
            }
        }
    }
    
    @objc public class func setDefaultState() {
        if let infoPlist = Bundle.main.infoDictionary, let statusBarHidden = infoPlist["UIStatusBarHidden"] as? Bool {
            StatusBarOverlay.prefersStatusBarHidden = statusBarHidden
        }
        else {
            StatusBarOverlay.prefersStatusBarHidden = false
        }
        
        if let infoPlist = Bundle.main.infoDictionary, let statusBarStyle = infoPlist["UIStatusBarStyle"] as? String, statusBarStyle == "UIStatusBarStyleLightContent" {
            StatusBarOverlay.preferredStatusBarStyle = .lightContent
        }
        else {
            // UIStatusBarStyleDefault
            StatusBarOverlay.preferredStatusBarStyle = .default
        }
    }
    
    private class func setNeedsStatusBarAppearanceUpdate() {
        UIView.animate(withDuration: 0.2, animations: {
            StatusBarOverlay.topViewController?.setNeedsStatusBarAppearanceUpdate()
            StatusBarOverlay.topViewController?.navigationController?.navigationBar.setNeedsLayout()
            StatusBarOverlay.topViewController?.navigationController?.navigationBar.layoutIfNeeded()
        })
    }
    
    @objc public class func setStatusBarText(_ statusBarText: String?, backgroundColor: UIColor?) {
        
        StatusBarOverlay.customStatusBarText = statusBarText
        StatusBarOverlay.shared.statusBarOverlayViewController?.setStatusBarFont(font: StatusBarOverlay.defaultFont)
        StatusBarOverlay.shared.statusBarOverlayViewController?.setStatusBarBackgroundColor(color: backgroundColor != nil ? backgroundColor! : StatusBarOverlay.defaultBackgroundColor)
        
        StatusBarOverlay.shared.update(isReachable: StatusBarOverlay.isReachable, animated: StatusBarOverlay.isReachable)
    }
    
    @objc public class func showMessage(_ message: String?, animated: Bool, duration: Double = 0, doShowArrow: Bool = false, messageHandler: (() -> Void)? = nil) {
        
        StatusBarOverlay.shared.statusBarOverlayViewController?.arrowImageView.isHidden = doShowArrow == false
        StatusBarOverlay.messageHandler = messageHandler
        
        StatusBarOverlay.shared.statusBarOverlayViewController?.setMessageBarText(text: message)
        StatusBarOverlay.hasMessage = message != nil
        
        StatusBarOverlay.shared.statusBarOverlayViewController?.setMessageBarBackgroundColor(color: StatusBarOverlay.defaultBackgroundColor)
        
        StatusBarOverlay.shared.update(isReachable: StatusBarOverlay.isReachable, animated: animated)
        
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
    
    @objc public class func removeMessage() {
        StatusBarOverlay.hasMessage = false
        
        StatusBarOverlay.shared.update(isReachable: StatusBarOverlay.isReachable, animated: true)
    }
    
    func update(isReachable: Bool, animated: Bool) {
        self.isHidden = false
        self.statusBarOverlayViewController?.setHasNotch(StatusBarOverlay.hasNotch)
        
        if isReachable {
            NotificationCenter.default.post(name: StatusBarOverlay.networkChangedToReachableNotification, object: nil)
        }
        
        if isReachable && StatusBarOverlay.customStatusBarText == nil {
            StatusBarOverlay.shared.statusBarOverlayViewController!.statusBarConstraintHeight.constant = 0
            
            StatusBarOverlay.prefersNoConnectionBarHidden = true
            StatusBarOverlay.preferredStatusBarUpdateAnimation = animated ? UIStatusBarAnimation.slide : UIStatusBarAnimation.none
            UIView.animate(withDuration: animated ? 0.2 : 0, animations: {
                StatusBarOverlay.topViewController?.setNeedsStatusBarAppearanceUpdate()
            })
            
            UIView.animate(withDuration: animated ? 0.3 : 0, animations: { () -> Void in
                
                let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: StatusBarOverlay.hasMessage ? 44 : 0)
                self.frame = frame
                self.layoutIfNeeded()
            })
        }
        else {
            StatusBarOverlay.shared.statusBarOverlayViewController?.setStatusBarTextColor(color: StatusBarOverlay.defaultTextColor)
            StatusBarOverlay.shared.statusBarOverlayViewController?.setShowStatusBarIconHidden(isReachable)
            self.updateStatusBarText(isReachable: isReachable)
            
            let statusBarHeight: CGFloat = StatusBarOverlay.hasNotch ? 44 :  20
            
            StatusBarOverlay.shared.statusBarOverlayViewController!.statusBarConstraintHeight.constant = statusBarHeight
            StatusBarOverlay.prefersNoConnectionBarHidden = false
            StatusBarOverlay.preferredStatusBarUpdateAnimation = animated ? UIStatusBarAnimation.slide : UIStatusBarAnimation.none
            UIView.animate(withDuration: animated ? 0.2 : 0, animations: {
                StatusBarOverlay.topViewController?.setNeedsStatusBarAppearanceUpdate()
            })
            
            UIView.animate(withDuration: animated ? 0.3 : 0, animations: { () -> Void in
                
                let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: statusBarHeight + (StatusBarOverlay.hasMessage ? 44 : 0))
                self.frame = frame
                self.layoutIfNeeded()
            })
        }
    }
    
    private func updateStatusBarText(isReachable: Bool) {
        // set custom status bar text, if any
        if StatusBarOverlay.customStatusBarText != nil && isReachable == false {
            StatusBarOverlay.shared.statusBarOverlayViewController?.setStatusBarText(text: StatusBarOverlay.customStatusBarText! + (StatusBarOverlay.hasNotch ? "" : " - \(StatusBarOverlay.defaultText)"))
        }
        else if StatusBarOverlay.customStatusBarText != nil {
            StatusBarOverlay.shared.statusBarOverlayViewController?.setStatusBarText(text: StatusBarOverlay.customStatusBarText)
        }
        else {
            StatusBarOverlay.shared.statusBarOverlayViewController?.setStatusBarText(text: (StatusBarOverlay.hasNotch ? StatusBarOverlay.defaultNotchText : StatusBarOverlay.defaultText))
        }
    }
    
    @IBAction func messageTapped(_ sender: UIButton) {
        StatusBarOverlay.messageHandler?()
        StatusBarOverlay.removeMessage()
    }
    
    @IBAction func closeTapped(_ sender: UIButton) {
        StatusBarOverlay.removeMessage()
    }
    
    @IBAction func statusBarTapped(_ sender: UIButton) {
        StatusBarOverlay.shared.update(isReachable: StatusBarOverlay.isReachable, animated: true)
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
}

/*public class MyReachability {
    
    // backup check as AlamoFire has a bug
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr()
        zeroAddress.sa_len = UInt8(MemoryLayout<sockaddr>.size)
        zeroAddress.sa_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else { return false }
        
        var flags = SCNetworkReachabilityFlags()
        guard SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) else { return false }
        
        return flags.contains(.reachable) && !flags.contains(.connectionRequired)
    }
}*/

