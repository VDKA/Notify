# Notify

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CI Status](https://travis-ci.org/VDKA/Notify.svg?branch=master)](https://travis-ci.org/VDKA/Notify)

Notify allows you to present notifications to your users with a simple interface.

![Hello](https://github.com/vdka/Notify/blob/master/Resources/Hello.gif)

```swift
Notify(title: "Hello world!").present()
```

## Customization

```swift
init(title: String, backgroundColor: UIColor = .orangeColor(), titleColor: UIColor = Notify.currentStatusBarTextColor, font: UIFont = .boldSystemFontOfSize(12))
func present(dismiss dismiss: Dismissal = .After(2.0), completion: (() -> Void)? = nil)
```

```swift
enum Dismissal {
  case After(NSTimeInterval)
  case OnTap
}
```

## Recommended Extension

In order to match the current status bar Notify calls `preferredStatusBarStyle()` & `preferredStatusBarHidden()` on the `keyWindow` of your apps `rootViewController`.

If your application's `rootViewController` is typically a `UINavigationController` or subclass thereof, then without this extension it will be the one to decide the visuals of your status bar.

```swift
extension UINavigationController {
  public override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return topViewController?.preferredStatusBarStyle() ?? .Default
  }

  public override func prefersStatusBarHidden() -> Bool {
    return topViewController?.prefersStatusBarHidden() ?? false
  }
}
```

