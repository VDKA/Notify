//
//  Notify.swift
//  Notify
//
//  Created by Ethan Jackwitz on 4/21/16.
//

import UIKit

public struct Notify {
  
  public var title: String
  public var backgroundColor: UIColor
  public var titleColor: UIColor
  public var font: UIFont
  
  public init(title: String, backgroundColor: UIColor = .orangeColor(), titleColor: UIColor = Notify.currentStatusBarTextColor, font: UIFont = .boldSystemFontOfSize(12)) {
    self.title = title
    self.backgroundColor = backgroundColor
    self.titleColor = titleColor
    self.font = font
  }
  
  /// NOTE: Notification is always dismissable by Tap
  public func present(dismiss dismiss: Dismissal = .After(2.0), completion: (() -> Void)? = nil) {
    Notifier.shared.titleLabel.text = title
    Notifier.shared.titleLabel.font = font
    Notifier.shared.titleLabel.textColor = titleColor
    Notifier.shared.view.backgroundColor = backgroundColor
    Notifier.shared.notificationWindow.backgroundColor = backgroundColor
    
    Notifier.shared.notificationWindow.windowLevel = UIWindowLevelStatusBar - 1 // Move the window to front
    
    Notifier.shared.setupFrames()
    
    Notifier.shared.completion = completion
    Notifier.shared.present(dismiss: dismiss)
  }
  
  public enum Dismissal {
    case After(NSTimeInterval)
    case OnTap
  }
}


// MARK: - Internals

extension Notify {
  internal static var currentStatusBarTextColor: UIColor {
    switch UIApplication.sharedApplication().keyWindow?.rootViewController?.preferredStatusBarStyle() {
    case .Default?: return .blackColor()
    case .LightContent?: return .whiteColor()
    default: return .whiteColor()
    }
  }
}


internal class Notifier: UIViewController {
  
  static var statusBarHeight: CGFloat {
    let statusBarSize = UIApplication.sharedApplication().statusBarFrame.size
    return min(statusBarSize.width, statusBarSize.height)
    
    // NOTE: This gets around a _bug_ in iOS that results in the frame of the status bar not being updated after a rotation.
  }
  
  static let shared: Notifier = Notifier()
  
  lazy var notificationWindow: UIWindow = UIWindow()
  var mainWindow = UIApplication.sharedApplication().keyWindow
  
  lazy var titleLabelHeight: CGFloat = 15.0
  
  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.frame.origin.y = Notifier.statusBarHeight
    label.textAlignment = .Center
    label.font = UIFont.systemFontOfSize(13)
    return label
  }()
  
  var viewcontroller: UIViewController?
  var hideTimer = NSTimer()
  var completion: (() -> Void)?
  
  
  // MARK: - Initializers
  
  override init(nibName nibNameOrNil: String?, bundle nibBndleOrNil: NSBundle?) {
    super.init(nibName: nil, bundle: nil)
    
    setupWindow()
    view.clipsToBounds = true
    view.addSubview(titleLabel)

    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(orientationDidChange), name: UIDeviceOrientationDidChangeNotification, object: nil)
    
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
    view.addGestureRecognizer(tapGestureRecognizer)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
  }
  
  
  // MARK: - Configuration
  
  func setupWindow() {
    notificationWindow.addSubview(view)
    notificationWindow.rootViewController = self
    notificationWindow.clipsToBounds = true
    notificationWindow.windowLevel = UIWindowLevelStatusBar - 1
  }
  
  func setupFrames() {
    let labelWidth = UIScreen.mainScreen().bounds.width
    let defaultHeight = titleLabelHeight
    
    if let text = titleLabel.text {
      let neededDimensions =
        NSString(string: text).boundingRectWithSize(
          CGSize(width: labelWidth, height: CGFloat.infinity),
          options: NSStringDrawingOptions.UsesLineFragmentOrigin,
          attributes: [NSFontAttributeName: titleLabel.font],
          context: nil
        )
      titleLabelHeight = CGFloat(neededDimensions.size.height)
      titleLabel.numberOfLines = 0 // Allows unwrapping
      
      if titleLabelHeight < defaultHeight {
        titleLabelHeight = defaultHeight
      }
    } else {
      titleLabel.sizeToFit()
    }
    
    let pad: CGFloat = 2
    notificationWindow.frame = CGRect(x: 0, y: 0, width: labelWidth, height: Notifier.statusBarHeight + titleLabelHeight - pad)
    view.frame = notificationWindow.frame
    titleLabel.frame = CGRect(x: 0, y: Notifier.statusBarHeight - 2 * pad, width: labelWidth, height: titleLabelHeight)
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return mainWindow?.rootViewController?.preferredStatusBarStyle() ?? .Default
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return mainWindow?.rootViewController?.prefersStatusBarHidden() ?? false
  }
  
  
  // MARK: - Movement methods
  
  func present(dismiss dismiss: Notify.Dismissal) {
    hideTimer.invalidate()
    
    notificationWindow.makeKeyAndVisible()
    setNeedsStatusBarAppearanceUpdate()
    
    let initialOrigin = notificationWindow.frame.origin.y
    notificationWindow.frame.origin.y = initialOrigin - (Notifier.statusBarHeight + titleLabelHeight)
    UIView.animateWithDuration(0.2, animations: { 
      self.notificationWindow.frame.origin.y = initialOrigin
    }, completion: { _ in
      self.setNeedsStatusBarAppearanceUpdate()
    })
    
    guard case .After(let t) = dismiss else { return }
    hideTimer = NSTimer.scheduledTimerWithTimeInterval(t, target: self, selector: #selector(timerDidFire), userInfo: nil, repeats: false)
  }
  
  func hide() {
    let finalOrigin = view.frame.origin.y - (Notifier.statusBarHeight + titleLabelHeight)
    UIView.animateWithDuration(0.2, animations: {
        self.notificationWindow.frame.origin.y = finalOrigin

      }, completion: { _ in
        self.mainWindow?.makeKeyAndVisible()
        self.notificationWindow.windowLevel = UIWindowLevelNormal - 1
        self.completion?()
    })
  }
  
  
  // MARK: - Gesture method
  
  func onTap() {
    hideTimer.invalidate() // ensure hide isn't called twice.
    hide()
  }
  
  // MARK: - Timer methods
  
  func timerDidFire() {
    hide()
  }
  
  func orientationDidChange() {
    guard notificationWindow.keyWindow else { return }
    setupFrames()
    hide()
  }
  
}
