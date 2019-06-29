# KPPaymentSDK

[![Swift 5](https://img.shields.io/badge/Swift-5-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Platforms iOS](https://img.shields.io/badge/Platforms-iOS-lightgray.svg?style=flat)](http://www.apple.com/ios/)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg)](https://github.com/Carthage/KPPaymentSDK)
[![Version](https://img.shields.io/cocoapods/v/KPPaymentSDK.svg?style=flat)](http://cocoapods.org/pods/KPPaymentSDK)
[![License BSD](https://img.shields.io/badge/License-BSD-lightgrey.svg?style=flat)](https://opensource.org/licenses/BSD-3Clause)

KPPaymentSDK is a kiplePay deeplink framework written in Swift, created for [kiplePay](https://kiplepay.com) app.
It uses CryptoSwift.

## Usage

```swift
import UIKit
import KPPaymentSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    .
    .
    .
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = KPPaymentApplicationDelegate.shared.application(app, open: url, options: options)
        return handled
    }
}
```

```swift
import UIKit
import KPPaymentSDK

class ViewController: UIViewController, KPPaymentDelegate {

    private let payment = KPPayment(merchantId: <YOUR_MERCHANT_ID>, secret: "<YOUR_SECRET>", isProduction: false)

    override func viewDidLoad() {
        super.viewDidLoad()

        self.payment.delegate = self
    }

    @IBAction func payButtonTapped(_ sender: UIButton) {
        self.payment.makePaymentForStoreId(<YOUR_STORE_ID>, withType: .Payment, withReferenceId: "<UNIQUE_REFERENCE_ID>", andAmount: 12.34)
    }

    func paymentDidFinishSuccessfully(_ flag: Bool, withMessage message: String, andPayload payload: [String : String]) {
        if flag {
            // handle payment is successful
        } else {
            // handle payment is not successful
        }
    }
}
```

## Requirements

- iOS 9.0+
- Xcode 10.2+

## Installation

#### <img src="https://cloud.githubusercontent.com/assets/432536/5252404/443d64f4-7952-11e4-9d26-fc5cc664cb61.png" width="24" height="24"> [Carthage]

[Carthage]: https://github.com/Carthage/Carthage

To install it, simply add the following line to your **Cartfile**:

```ruby
github "m2c/KPPaymentSDK"
```

Then run `carthage update`.

Follow the current instructions in [Carthage's README][carthage-installation]
for up to date installation instructions.

[carthage-installation]: https://github.com/Carthage/Carthage#adding-frameworks-to-an-application

#### <img src="https://raw.githubusercontent.com/m2c/KPPaymentSDK/master/Resources/Images/cocoapods.png" width="24" height="24"> [CocoaPods]

[CocoaPods]: http://cocoapods.org

To install it, simply add the following line to your Podfile:

```ruby
pod 'KPPaymentSDK'
```

You will also need to make sure you're opting into using frameworks:

```ruby
use_frameworks!
```

Then run `pod install` with CocoaPods 1.6.0 or newer.

#### Manually

KPPaymentSDK in your project requires the following steps:

1. Add KPPaymentSDK as a [submodule](http://git-scm.com/docs/git-submodule) by opening the Terminal, `cd`-ing into your top-level project directory, and entering the command `git submodule add https://github.com/m2c/KPPaymentSDK.git`
2. Open the `KPPaymentSDK` folder, and drag `KPPaymentSDK.xcodeproj` into the file navigator of your app project.
3. In Xcode, navigate to the target configuration window by clicking on the blue project icon, and selecting the application target under the "Targets" heading in the sidebar.
4. Ensure that the deployment target of `KPPaymentSDK.framework` matches that of the application target.
5. In the tab bar at the top of that window, open the "Build Phases" panel.
6. Expand the "Link Binary with Libraries" group, and add `KPPaymentSDK.framework`.
7. Click on the `+` button at the top left of the panel and select "New Copy Files Phase". Rename this new phase to "Copy Frameworks", set the "Destination" to "Frameworks", and add `KPPaymentSDK.framework`.

### Author

- [Kiple Sdn Bhd and its affiliates](http://github.com/m2c) ([@m2c](https://kiplepay.com))

### License

KPPaymentSDK is released under the BSD license. See [LICENSE] for details.

[LICENSE]: /LICENSE